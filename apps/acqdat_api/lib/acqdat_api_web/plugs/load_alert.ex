defmodule AcqdatApiWeb.Plug.LoadAlert do
  @moduledoc """
  Plug to verify if alert exist before taking action like updation, deletion or just showing it.
  """
  import Plug.Conn
  alias AcqdatCore.Alerts.Model.Alert, as: ARModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => alert_id}} = conn, _params) do
    check_alert(conn, alert_id)
  end

  def call(%{params: %{"alert_id" => alert_id}} = conn, _params) do
    check_alert(conn, alert_id)
  end

  defp check_alert(conn, alert_id) do
    {alert_id, _} = Integer.parse(alert_id)

    case ARModel.get_by_id(alert_id) do
      {:ok, alert} ->
        assign(conn, :alert, alert)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
