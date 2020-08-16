defmodule AcqdatApiWeb.Plug.LoadAlertRules do
  @moduledoc """
  Plug to verify if alert rule exist before taking action like updation, deletion or just showing it.
  """
  import Plug.Conn
  alias AcqdatCore.Alerts.Model.AlertRules, as: ARModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => alert_rules_id}} = conn, _params) do
    check_rule(conn, alert_rules_id)
  end

  def call(%{params: %{"alert_rules_id" => alert_rules_id}} = conn, _params) do
    check_rule(conn, alert_rules_id)
  end

  defp check_rule(conn, alert_rules_id) do
    {alert_rules_id, _} = Integer.parse(alert_rules_id)

    case ARModel.get_by_id(alert_rules_id) do
      {:ok, alert_rule} ->
        assign(conn, :alert_rule, alert_rule)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
