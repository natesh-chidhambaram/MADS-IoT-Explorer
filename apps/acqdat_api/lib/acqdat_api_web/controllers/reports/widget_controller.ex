defmodule AcqdatApiWeb.Reports.WidgetController do
  use AcqdatApiWeb, :authorized_controller

  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Reports.Widget

  alias AcqdatApi.Reports.Widget
  alias AcqdatApiWeb.Reports.WidgetErrorHelper

  # TODO avoid having the schema call in controller.
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  plug AcqdatApiWeb.Plug.LoadWidget when action in [:show]
  plug :put_view, AcqdatApiWeb.Widgets.WidgetView when action in [:show]
  plug :put_view, AcqdatApiWeb.DashboardManagement.WidgetInstanceView when action in [:data]

  # fetch widgets
  def index(conn, params) do
    changeset = verify_widget_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, widgets} = {:list, Widget.get_all_by_classification_not_standard(data)}

        conn
        |> put_status(200)
        |> render("widgets.json", %{data: widgets})

      404 ->
        conn
        |> send_error(404, DashboardErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardErrorHelper.error_message(:unauthorized))
    end
  end

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

  def data(conn, %{"id" => id} = params) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        case Widget.get_by_filter(id, params) do
          {:error, message} ->
            conn
            |> send_error(400, WidgetErrorHelper.error_message(:resource_not_found))

          {:ok, widget} ->
            conn
            |> put_status(200)
            |> render("show.json", %{widget_instance: widget})
        end

      404 ->
        conn
        |> send_error(404, WidgetInstanceErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetInstanceErrorHelper.error_message(:unauthorized))
    end
  end

end
