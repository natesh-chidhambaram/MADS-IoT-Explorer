defmodule AcqdatApi.GatewayDataSupervisorTest do
  use ExUnit.Case, async: true
  alias AcqdatApi.Helper.GatewayDataSupervisor

  setup do
    {:ok, uuid: 123, uuid2: 234}
  end


  test "starts a new child process", context do
    # start_supervised(GatewayDataSupervisor)
    # %{workers: workers_initially } = children_before = Supervisor.count_children(GatewayDataSupervisor)
    # assert workers_initially == 0

    # %{active: _active, specs: _specs, supervisors: _s, workers: workers_before } = children_before = Supervisor.count_children(GatewayDataSupervisor)
    # # IO.inspect(children_before, label: "before - starts new child")

    # GatewayDataSupervisor.start_child(context.uuid)
    # %{active: _active, specs: _specs, supervisors: _s, workers: workers_after } =  children_after = Supervisor.count_children(GatewayDataSupervisor)
    # # IO.inspect(children_after, label: "after start new child")

    # assert (workers_before + 1) == workers_after
    #   stop_supervised(GatewayDataSupervisor)

    end

  test "stops a child process", context do
    # start_supervised(GatewayDataSupervisor)
    start_supervised(GatewayDataSupervisor)

    %{workers: workers_initially } = children_before = Supervisor.count_children(GatewayDataSupervisor)
    assert workers_initially == 0

    GatewayDataSupervisor.start_child(context.uuid)
    GatewayDataSupervisor.start_child(context.uuid2)

    %{active: _active, specs: _specs, supervisors: _s, workers: workers_before } = children_before = Supervisor.count_children(GatewayDataSupervisor)
    IO.inspect(children_before, label: "before")

    IO.inspect Supervisor.which_children(GatewayDataSupervisor)
    GatewayDataSupervisor.stop_child(context.uuid)
    IO.inspect Supervisor.which_children(GatewayDataSupervisor)

    %{active: _active, specs: _specs, supervisors: _s, workers: workers_after } =  children_after = Supervisor.count_children(GatewayDataSupervisor)
    IO.inspect(children_after, label: "after")

    assert (workers_before - 1) == workers_after
      stop_supervised(GatewayDataSupervisor)

    end



end
