defmodule CoolingPump2 do
  alias Weave.{Library, Context, Action}

  @moduledoc """
  CoolingPump sample pipeline

  The gateway sends three temperature values in payload and we want to:
  - compute the average temperature.
  - control a cooling pump based on the temperature.

  The average temperature is stored as a new time series and pump state is
  tracked in metadata of the project.
  If the pump state differs from the desired state an MQTT message is to be
  sent.

  ## Example
  init_state = {:ok, %{type: :telemetry, t1: 12, t2: 13, t3: 57.2}, %Weave.Context{project: %{pump_state: :on}}}
  {root, tree} = CoolingPump2.build
  CoolingPump2.exec(:bb0, init_state, CoolingPump2.build)
  """

  @type action() :: Action.t()
  @type link() :: {atom(), [atom()]}
  @type block() :: {action(), [link()]}
  @type dag :: {root :: atom(), dag :: %{atom() => block()}}

  @type state :: {atom(), map(), Context.t()}
  @type result :: {atom(), state(), [result()]}

  @spec build() :: dag()
  def build do
    {:bb0,
     %{
       bb0: {%Library.Init{}, [bb1: [:telemetry], bb4: [:telemetry]]},
       bb1: {%Library.Switch{}, [bb2: [:telemetry]]},
       bb2: {%Library.MapLambda{options: f2c()}, [bb3: [:ok]]},
       bb3: {%Library.WriteTimeSeries{options: project_nil()}, []},
       bb4: {%Library.MapLambda{options: f2c()}, [bb5: [:ok]]},
       bb5: {%Library.MapLambda{options: avg()}, [bb6: [:ok], bb7: [:ok]]},
       bb6: {%Library.WriteTimeSeries{options: project_nil()}, []},
       bb7: {%Library.ReadTimeSeries{options: read_avg()}, [bb8: [:ok]]},
       bb8: {%Library.MapLambda{options: pump_cond()}, [bb9: [:ok]]},
       bb9: {%Library.ReadState{options: read_pump()}, [bb10: [:ok]]},
       bb10: {%Library.Condition{options: pump_update_cond()}, [bb11: [true], bb12: [true]]},
       bb11: {%Library.SendMqtt{options: project_nil()}, []},
       bb12: {%Library.WriteState{options: write_pump()}, []}
     }}
  end

  @spec exec(atom(), state(), dag()) :: result()
  def exec(bb, {_, event, context}, {_, dag} = pipeline) do
    {action, links} = dag[bb]

    case Weave.Action.exec(action, event, context) do
      {:error, _, _} = xstate ->
        {bb, xstate, []}

      {xlabel, _xevent, _xcontext} = xstate ->
        outedges = Enum.filter(links, fn {_, labels} -> Enum.member?(labels, xlabel) end)

        case outedges do
          [] ->
            {bb, xstate, []}

          [{dest, _} | []] ->
            {bb, xstate, [exec(dest, xstate, pipeline)]}

          _ ->
            subtasks =
              Task.Supervisor.async_stream(
                Weave.TaskSupervisor,
                outedges,
                fn {dest, _} -> exec(dest, xstate, pipeline) end,
                max_concurrency: 6,
                ordered: false
              )
              |> Enum.reduce([], fn
                subresult, acc -> [subresult | acc]
              end)

            {bb, xstate, subtasks}
        end
    end
  end

  defp project_nil do
    %{projections: [fn _ -> nil end]}
  end

  defp write_pump do
    %{
      projection: fn %{pump_command: pump_command} -> pump_command end,
      destination: [:pump_state],
      scope: :project
    }
  end

  defp read_avg do
    %{
      projection: fn _ -> 16 end,
      destination: [:prev_average]
    }
  end

  defp f2c do
    %{
      projections: [fn %{t3: t3} -> t3 end],
      program: fn farenheit -> (farenheit - 32) * 5 / 9 end,
      destination: {:event, [:t3]}
    }
  end

  defp avg do
    %{
      projections: [
        fn %{t1: t} -> t end,
        fn %{t2: t} -> t end,
        fn %{t3: t} -> t end
      ],
      program: fn t1, t2, t3 -> (t1 + t2 + t3) / 3 end,
      destination: {:event, [:average]}
    }
  end

  defp pump_cond do
    %{
      projections: [
        fn %{average: t} -> t end,
        fn %{prev_average: t} -> t end
      ],
      program: fn
        average, prev_average when average > 42 -> if average > prev_average, do: :on, else: :off
        _, _ -> :off
      end,
      destination: {:event, [:pump_command]}
    }
  end

  defp read_pump do
    %{
      projection: fn context -> context.project[:pump_state] end,
      destination: [:pump_state]
    }
  end

  defp pump_update_cond do
    %{
      projections: [
        fn %{pump_state: pump_state} -> pump_state end,
        fn %{pump_command: pump_command} -> pump_command end
      ],
      predicate: fn pump_state, pump_command -> pump_state != pump_command end
    }
  end
end
