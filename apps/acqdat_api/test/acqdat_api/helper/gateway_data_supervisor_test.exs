defmodule AcqdatApi.GatewayDataSupervisorTest do
  use ExUnit.Case, async: true
  alias AcqdatApi.Helper.GatewayDataSupervisor

  setup do
    start_supervised(GatewayDataSupervisor)
    {:ok, uuid: 123, uuid2: 234}
  end


  test "starts a new child process", context do
    %{active: _active, specs: _specs, supervisors: _s, workers: workers_before } = children_before = Supervisor.count_children(GatewayDataSupervisor)
    # IO.inspect(children_before, label: "before - starts new child")

    GatewayDataSupervisor.start_child(context.uuid)
    %{active: _active, specs: _specs, supervisors: _s, workers: workers_after } =  children_after = Supervisor.count_children(GatewayDataSupervisor)
    # IO.inspect(children_after, label: "after start new child")

    assert (workers_before + 1) == workers_after
  end

  test "stops a child process", context do
    # start_supervised(GatewayDataSupervisor)
    GatewayDataSupervisor.start_child(context.uuid)

    %{active: _active, specs: _specs, supervisors: _s, workers: workers_before } = children_before = Supervisor.count_children(GatewayDataSupervisor)
    # IO.inspect(children_before, label: "before")

    GatewayDataSupervisor.stop_child(context.uuid)

    %{active: _active, specs: _specs, supervisors: _s, workers: workers_after } =  children_after = Supervisor.count_children(GatewayDataSupervisor)
    # IO.inspect(children_after, label: "after")

    assert (workers_before - 1) == workers_after
  end



end
