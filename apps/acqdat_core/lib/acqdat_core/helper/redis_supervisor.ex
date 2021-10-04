defmodule AcqdatCore.Helper.RedisSupervisor do
  use Supervisor

  alias AcqdatCore.Helper.Redis

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      Redis.child()
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
