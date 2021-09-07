defmodule CoolingPump do
  alias Weave.{Library, Context, Action}

  @moduledoc """
  Documentation for `CoolingPump`.
  """

  @type action() :: Action.t()
  @type link() :: {atom(), [atom()]}
  @type block() :: {[action()], [link()]}
  @type dag :: {root :: atom(), dag :: %{atom() => block()}}

  @type state :: {atom(), map(), Context.t()}
  # i = {:ok, %{type: :telemetry, t1: 12, t2: 13, t3: 57.2}, %Weave.Context{project: %{pump_state: :on}}}
  
  @spec build() :: dag()
  def build do
    {:bb0,
     %{
       bb0: {[%Library.Init{}, %Library.Switch{}], [{:bb1, [:telemetry]}, {:bb2, [:telemetry]}]},
       bb1:
         {[%Library.MapLambda{options: f2c()}, %Library.WriteTimeSeries{options: project_nil()}],
          []},
       bb2:
         {[
            %Library.MapLambda{options: f2c()},
            %Library.MapLambda{options: avg()}
          ], [{:bb3, [:ok]}, {:bb4, [:ok]}]},
       bb3: {[%Library.WriteTimeSeries{options: project_nil()}], []},
       bb4:
         {[
            %Library.ReadTimeSeries{options: read_avg()},
            %Library.MapLambda{options: pump_cond()},
            %Library.ReadState{options: read_pump()},
            %Library.Condition{options: pump_update_cond()}
          ], [{:bb5, [true]}, {:bb6, [true]}]},
       bb5: {[%Library.SendMqtt{options: project_nil()}], []},
       bb6: {[%Library.WriteState{options: write_pump()}], []}
     }}
  end

  @type result :: {atom(), state(), [result()]}

  @spec exec_block(atom(), state(), dag()) :: result()
  def exec_block(bb, state, {_, tree} = dag) do
    {actions, links} = tree[bb]

    {exit_label, _exit_event, exit_context} =
      exit_state =
      Enum.reduce_while(actions, state, fn
        _, {:halt, event, context} -> {:halt, {:ok, event, context}}
        _, {:error, _, _} = state -> {:halt, state}
        action, {_, event, context} -> {:cont, Action.exec(action, event, context)}
      end)

    subtasks = Task.Supervisor.async_stream(
      Weave.TaskSupervisor,
      links,
      fn
        {bb, labels} ->
          if exit_label in labels do
            exec_block(bb, exit_state, dag)
          else
            {bb, {:ok, exit_state, exit_context}, []}
          end
      end,
      max_concurrency: 6, ordered: false
    )
    |> Enum.reduce([], fn
      {:ok, result}, acc -> [result | acc]
      {:exit, reason}, acc -> [reason | acc]
    end)

    {bb, exit_state, subtasks}
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
