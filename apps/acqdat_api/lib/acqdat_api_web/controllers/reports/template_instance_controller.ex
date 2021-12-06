defmodule AcqdatApiWeb.Reports.TemplateInstanceController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers

  import AcqdatApiWeb.Validators.Reports.TemplateInstance
  alias AcqdatApiWeb.Reports.TemplateInstanceErrorHelper
  alias AcqdatApi.Reports.TemplateInstance

  plug AcqdatApiWeb.Plug.LoadOrg when action in [:create, :update]
  plug AcqdatApiWeb.Plug.LoadTemplateInstance when action in [:update, :delete]

  def index(conn, params) do
    changeset = verify_index_params(params)
    {:ok, data} = extract_changeset_data(changeset)
    template_instances = TemplateInstance.get_all(data)
    resp_data = %{template_instances: template_instances}

    conn
    |> put_status(200)
    |> render("index.json", resp_data)
  end

  def create(conn, params) do
    changeset =
      params
      |> Map.put("org_id", conn.assigns.org.id)
      |> verify_params()

    with {:extract, {:ok, data} = extract_changeset_data(changeset)},
         {:create, {:ok, template_instance}} <- {:create, TemplateInstance.create(data)} do
      conn
      |> put_status(200)
      |> render("show.json", %{template_instance: template_instance})
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, changeset}} ->
        message = extract_changeset_error(changeset)
        send_error(conn, 400, message)
    end
  end

  def show(conn, %{"id" => id} = _params) do
    {id, _} = Integer.parse(id)

    case TemplateInstance.get_by_id(id) do
      {:error, message} ->
        conn
        |> send_error(400, TemplateInstanceErrorHelper.error_message(:resource_not_found))

      {:ok, template_instance} ->
        conn
        |> put_status(200)
        |> render("show.json", %{template_instance: template_instance})
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        changeset =
          params
          |> Map.put("org_id", conn.assigns.org.id)
          |> verify_update_params()

        with {:extract, {:ok, data} = extract_changeset_data(changeset)},
             {:update, {:ok, template_instance}} <-
               {:update, TemplateInstance.update(conn.assigns.template_instance, data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{template_instance: template_instance})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:update, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, TemplateInstanceErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TemplateInstanceErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case TemplateInstance.delete(conn.assigns.template_instance) do
          {:ok, template_instance} ->
            conn
            |> put_status(200)
            |> render("show.json", %{template_instance: template_instance})

          {:else, template_instance} ->
            error =
              case String.valid?(template_instance) do
                false -> extract_changeset_error(template_instance)
                true -> template_instance
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, TemplateInstanceErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TemplateInstanceErrorHelper.error_message(:unauthorized))
    end
  end
end
