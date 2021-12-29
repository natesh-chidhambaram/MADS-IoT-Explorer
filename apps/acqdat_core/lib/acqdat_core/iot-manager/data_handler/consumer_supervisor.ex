defmodule AcqdatCore.IotManager.DataSupervisor do
  use ConsumerSupervisor
  alias AcqdatCore.IotManager.Server
  alias AcqdatCore.IotManager.DataWorker

  def start_link(_args) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      %{
        id: DataWorker,
        start: {DataWorker, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [
        {Server, max_demand: 60}
      ]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
