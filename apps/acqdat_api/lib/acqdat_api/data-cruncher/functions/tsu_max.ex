defmodule AcqdatApi.DataCruncher.Functions.TsuMax do
  @inports [:input]
  @outports [:output]

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid) do
    value = Enum.max(Map.get(inport_args, :input))
    {request_id, :reply, %{output: value}}
  end
end
