defmodule AcqdatApi.DataCruncher.Task do
  alias Virta.{Node, Registry, EdgeData}
  alias AcqdatApi.DataCruncher.Functions.{TsuMax, TsuMin}

  def parse_and_create_graph(params) do
    task_graph =
      Graph.new(type: :directed)
      |> Graph.add_edge(
        %Node{module: Virta.Core.In, id: 0},
        %Node{module: TsuMax, id: 1},
        label: %EdgeData{from: :input, to: :input}
      )
      |> Graph.add_edge(
        %Node{module: TsuMax, id: 1},
        %Node{module: Virta.Core.Out, id: 2},
        label: %EdgeData{from: :output, to: :output}
      )

    {:ok, "registered"} = Registry.register("task_graph", task_graph)

    data = %{
      %Node{module: Virta.Core.In, id: 0} => [{1, :input, [3, 1, 4, 1, 5, 9, 2, 6, 5, 4_863_856]}]
    }

    Virta.Executor.call("task_graph", data)
  end
end
