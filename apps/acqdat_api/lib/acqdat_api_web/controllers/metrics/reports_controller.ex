defmodule AcqdatApiWeb.Metrics.ReportsController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.Metrics.Reports
  alias AcqdatApiWeb.Metrics.ReportsErrorHelper
  alias AcqdatApiWeb.Validators.Metrics.ReportMetric

  plug AcqdatApiWeb.Plug.LoadCurrentUser when action in [:downloads]
  plug :put_view, AcqdatApiWeb.Notifications.NotificationView when action in [:downloads]

  def create(conn, params) do
    with nil <- conn.status,
         {:ok, params} <- ReportMetric.validate_params(params),
         {:ok, data} <- Reports.gen_report(params) do
      conn
      |> put_status(200)
      |> render("report_data.json", %{reports: data})
    else
      404 ->
        send_error(conn, 404, ReportsErrorHelper.error_message(:resource_not_found_role))

      401 ->
        send_error(conn, 401, ReportsErrorHelper.error_message(:unauthorized))

      {:validation_error, errors} ->
        errors = extract_changeset_error(errors)
        send_error(conn, 400, ReportsErrorHelper.error_message(:malformed_data, errors))

      {:error, message} ->
        send_error(conn, 400, ReportsErrorHelper.error_message(:gen_report_error, message))
    end
  end

  def downloads(conn, params) do
    case conn.status do
      nil ->
        case Reports.download_report(params, conn.assigns.current_user) do
          {:ok, data} ->
            conn
            |> put_status(200)
            |> render("notification.json", %{notification: data})

          {:error, %Ecto.Changeset{} = error} ->
            error = extract_changeset_error(error)
            send_error(conn, 400, error)

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

  def fetch_reports(conn, %{"name" => name}) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> json(%{presigned_url: Reports.get_presigned_url(name)})

      404 ->
        conn
        |> send_error(404, ReportsErrorHelper.error_message(:resource_not_found_role))

      401 ->
        conn
        |> send_error(401, ReportsErrorHelper.error_message(:unauthorized))
    end
  end
end
