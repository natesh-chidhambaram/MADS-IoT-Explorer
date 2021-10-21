defmodule AcqdatApi.Helper.GatewayDataActivity do
  use GenServer
  @timeout_seconds 120

  def start_link(project_uuid) do
    GenServer.start_link(__MODULE__, project_uuid, name: via_tuple(project_uuid))
  end

  @impl true
  def init(_stack) do
    {:ok, %{}}
  end

  def stop(project_uuid, stop_reason) do
    project_uuid |> via_tuple() |> GenServer.stop(stop_reason)
  end

  def log_activity(project_uuid, gateway_uuid) do
    project_uuid |> via_tuple() |> GenServer.cast({:add_gateway_activity, gateway_uuid})
  end

  def list_activity(project_uuid) do
    project_uuid |> via_tuple() |> GenServer.call(:show_gateway_activity)
  end

  # Supervisor needs this when stopping a child.
  def get_process_id(project_uuid) do
    project_uuid |> via_tuple()
  end

  def check_if_active(project_uuid, gateway_uuid) do
    project_uuid |> via_tuple() |> GenServer.call({:check_gateway_activity, gateway_uuid})
  end


  ## Genserver functions
  @impl true
  def handle_cast({:add_gateway_activity, gateway_uuid}, state) do
    timestamp = NaiveDateTime.utc_now()
    new_state = Map.put(state, gateway_uuid, timestamp)
    {:noreply, new_state}
  end

  def handle_call(:show_gateway_activity, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:check_gateway_activity, gateway_uuid}, _from, state) do
    {:reply, give_flag_for(state, gateway_uuid), state}
  end

  defp give_flag_for(map, gateway_uuid) do
    if input_time = Map.get(map, gateway_uuid) do
      NaiveDateTime.diff(NaiveDateTime.utc_now(), input_time, :millisecond) <
        :timer.seconds(@timeout_seconds)
    else
      false
    end
  end

  ## cleanup after a Day code
  # Discard all values not matching function
  # DateTime more than TWO_DAYS_IN_SECONDS

  defp via_tuple(project_uuid),
    do: {:via, Registry, {GatewayRegistry, project_uuid}}
end
