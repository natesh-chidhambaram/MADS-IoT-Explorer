defmodule AcqdatCore.IotManager.Server do
  @moduledoc """
  The producer stage for getting events from MQTT and HTTP handlers and sending
  data for forwarding to next stage.

  The stages consists of a simple producer using demand dispatch strategy with
  a consumer supervisor.

  We are using the internal buffer of the genstage to hold events.
  """

  use GenStage

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  def log_data(data) do
    GenServer.cast(__MODULE__, {:log_data, data})
  end

  @impl GenStage
  def init(_args) do
    {:producer, [], buffer_size: 20_000}
  end

  @impl GenStage
  def handle_cast({:log_data, data}, state) do
    {:noreply, [data], state}
  end

  @impl GenStage
  def handle_demand(_demand, state) do
    # We don't care about the demand
    {:noreply, [], state}
  end
end
