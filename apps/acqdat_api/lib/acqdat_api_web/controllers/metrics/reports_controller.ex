defmodule AcqdatApiWeb.Metrics.ReportsController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.Metrics.Reports
  alias AcqdatApiWeb.Metrics.ReportsErrorHelper

  def create(conn, params) do
    case conn.status do
      nil ->
        case Reports.gen_report(params) do
          {:ok, data} ->
            conn
            |> put_status(200)
            |> render("report_data.json", %{reports: data})

          {:error, message} ->
            send_error(conn, 400, ReportsErrorHelper.error_message(:gen_report_error, message))
        end

      404 ->
        conn
        |> send_error(404, ReportsErrorHelper.error_message(:resource_not_found_role))

      401 ->
        conn
        |> send_error(401, ReportsErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_headers(conn, _params) do
    case conn.status do
      nil ->
        headers = Reports.fetch_metrics_headers()

        conn
        |> put_status(200)
        |> render("headers_data.json", %{headers: headers})

      404 ->
        conn
        |> send_error(404, ReportsErrorHelper.error_message(:resource_not_found_role))

      401 ->
        conn
        |> send_error(401, ReportsErrorHelper.error_message(:unauthorized))
    end
  end
end
