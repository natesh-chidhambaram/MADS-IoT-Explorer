defmodule AcqdatApiWeb.Reports.WidgetInstanceController do
  use AcqdatApiWeb, :authorized_controller

  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Reports.WidgetInstance

  alias AcqdatApi.Reports.WidgetInstance
  alias AcqdatApiWeb.Reports.WidgetErrorHelper

  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  def create(conn, params) do
    changeset = verify_params(params)

    with {:extract, {:ok, data} = extract_changeset_data(changeset)},
         {:create, {:ok, widget}} <- {:create, WidgetInstance.create(data)} do
      conn
      |> put_status(200)
      |> render("show.json", %{widget: widget})
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, changeset}} ->
        message = extract_changeset_error(changeset)
        send_error(conn, 400, message)
    end
  end

  def show(conn, %{"id" => id} = params) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        case WidgetInstance.get_by_filter(id, params) do
          {:error, message} ->
            conn
            |> send_error(400, WidgetInstanceErrorHelper.error_message(:resource_not_found))

          {:ok, widget_instance} ->
            conn
            |> put_status(200)
            |> render("show.json", %{widget_instance: widget_instance})
        end

      404 ->
        conn
        |> send_error(404, WidgetInstanceErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetInstanceErrorHelper.error_message(:unauthorized))
    end
  end

  def data(conn, %{"id" => id} = params) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        case WidgetInstance.get_by_filter(id, params) do
          {:error, message} ->
            conn
            |> send_error(400, WidgetInstanceErrorHelper.error_message(:resource_not_found))

          {:ok, widget_instance} ->
            conn
            |> put_status(200)
            |> render("widget_data.json", %{widget_instance: widget_instance})
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
