defmodule AcqdatCore.IotManager.DataParser.Supervisor do
  use Supervisor

  alias AcqdatCore.IotManager.DataParser.Worker.{Server, Manager}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    children = [
      Server,
      Manager
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
