defmodule AcqdatCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      AcqdatCore.Repo,
      AcqdatCore.IotManager.CommandHandler,
      AcqdatCore.IotManager.Supervisor,
      AcqdatCore.MQTT.Supervisor,
      AcqdatCore.Domain.Notification.Supervisor,
      AcqdatCore.Alerts.Supervisor,
      AcqdatCore.Metrics.SchedulerSupervisor,
      AcqdatCore.EntityManagement.AlertCreation
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AcqdatCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
