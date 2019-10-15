defmodule AcqdatCore.Domain.Notification.Worker do
  use GenServer
  alias AcqdatCore.Domain.Notification
  alias AcqdatCore.Domain.Notification.Server

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_notificaton(pid, params) do
    GenServer.cast(pid, {:notify_handler, params})
  end

  @impl GenServer
  def init(_args) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:notify_handler, params}, _state) do
    Notification.handle_notification(params)
    Server.finished(self())
    {:noreply, nil}
  end
end
