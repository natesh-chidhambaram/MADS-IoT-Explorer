defmodule AcqdatCore.IotManager.DataWorker do
  alias AcqdatCore.IotManager.DataHandler

  def start_link(event) do
    Task.start_link(fn ->
      DataHandler.insert_data(event)
    end)
  end
end
