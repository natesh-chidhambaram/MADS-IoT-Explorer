defmodule AcqdatApiWeb.Reports.WidgetInstanceController do
  use AcqdatApiWeb, :authorized_controller

  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Reports.WidgetInstance
  alias AcqdatApiWeb.Reports.WidgetInstanceErrorHelper

  alias AcqdatApi.Reports.WidgetInstance
  alias AcqdatApiWeb.Reports.WidgetErrorHelper

  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts
  plug AcqdatApiWeb.Plug.LoadReportWidgetInstance when action in [:update, :delete]

  def create(conn, params) do
    changeset = verify_params(params)

    with {:extract, {:ok, data} = extract_changeset_data(changeset)},
         {:create, {:ok, widget_instance}} <- {:create, WidgetInstance.create(data)} do
      conn
      |> put_status(200)
      |> render("show.json", %{widget_instance: widget_instance})
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

  def update(conn, params) do
    case conn.status do
      nil ->
        case WidgetInstance.update(conn.assigns.widget_instance, params) do
          {:ok, widget_inst} ->
            conn
            |> put_status(200)
            |> render("show.json", %{widget_instance: widget_inst})

          {:error, message} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, WidgetInstanceErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetInstanceErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case WidgetInstance.delete(conn.assigns.widget_instance) do
          {:ok, widget_instance} ->
            conn
            |> put_status(200)
            |> render("show.json", %{widget_instance: widget_instance})

          {:error, widget_instance} ->
            error =
              case String.valid?(widget_instance) do
                false -> extract_changeset_error(widget_instance)
                true -> widget_instance
              end

            conn
            |> send_error(400, error)
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
