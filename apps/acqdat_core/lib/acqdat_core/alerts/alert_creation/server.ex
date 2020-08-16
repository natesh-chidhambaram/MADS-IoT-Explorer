defmodule AcqdatCore.Alerts.Server do
  @moduledoc """
  Service which will run alert creation logic asynchronously
  It will recieve the request from data parser module with the respective data that is being inserted into sensor or gateway data table.
  That object contatins ID with respective parameters for which data is being inserted.
  """
  use GenServer
  alias AcqdatCore.Alerts.AlertCreation

  def init(params) do
    {:ok, params}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def handle_cast({:gateway_alert, data}, _status) do
    response = AlertCreation.traverse_ids(data, "gateway")
    {:noreply, response}
  end

  def handle_cast({:sensor_alert, data}, _status) do
    response = AlertCreation.traverse_ids(data, "sensor")
    {:noreply, response}
  end
end
