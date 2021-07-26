defmodule AcqdatApiWeb.DashboardManagement.WidgetController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApiWeb.DashboardManagement.WidgetErrorHelper
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  plug AcqdatApiWeb.Plug.LoadWidget when action in [:show]
  plug :put_view, AcqdatApiWeb.Widgets.WidgetView when action in [:show]

  def show(conn, _params) do
    case conn.status do
      nil ->
        widget =
          conn.assigns.widget
          |> Map.put(
            :visual_prop,
            HighCharts.parse_properties(conn.assigns.widget.visual_settings)
          )
          |> Map.put(:data_prop, HighCharts.parse_properties(conn.assigns.widget.data_settings))

        conn
        |> put_status(200)
        |> render("widget.json", %{widget: widget})

      404 ->
        conn
        |> send_error(404, WidgetErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetErrorHelper.error_message(:unauthorized))
    end
  end
end
