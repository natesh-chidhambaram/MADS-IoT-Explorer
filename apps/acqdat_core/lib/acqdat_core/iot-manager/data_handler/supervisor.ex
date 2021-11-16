defmodule AcqdatCore.IotManager.Supervisor do
  use Supervisor

  alias AcqdatCore.IotManager.Server
  alias AcqdatCore.IotManager.DataSupervisor
  alias AcqdatCore.IotManager.DataDump.ErrorCron

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      Server,
      DataSupervisor,
      ErrorCron
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
