defmodule AcqdatApiWeb.Reports.TemplateController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers

  import AcqdatApiWeb.Validators.Reports.Template
  alias AcqdatApiWeb.Reports.TemplateErrorHelper
  alias AcqdatApi.Reports.Templates

  plug AcqdatApiWeb.Plug.LoadTemplate when action in [:update, :delete]

  def index(conn, params) do
    changeset = verify_index_params(params)

    # TODO pagination
    {:ok, data} = extract_changeset_data(changeset)

    templates = Templates.get_all(data)
    resp_data = %{templates: templates}

    conn
    |> put_status(200)
    |> render("index.json", resp_data)
  end

  def create(conn, params) do
    changeset = verify_params(params)

    with {:extract, {:ok, data} = extract_changeset_data(changeset)},
         {:create, {:ok, template}} <- {:create, Templates.create(data)} do
      conn
      |> put_status(200)
      |> render("show.json", %{template: template})
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

    case Templates.get_by_id(id) do
      {:error, message} ->
        conn
        |> send_error(400, TemplateErrorHelper.error_message(:resource_not_found))

      {:ok, template} ->
        conn
        |> put_status(200)
        |> render("show.json", %{template: template})
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_update_params(params)

        with {:extract, {:ok, data} = extract_changeset_data(changeset)},
             {:update, {:ok, template}} <-
               {:update, Templates.update(conn.assigns.template, data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{template: template})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:update, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, TemplateErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TemplateErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case Templates.delete(conn.assigns.template) do
          {:ok, template} ->
            conn
            |> put_status(200)
            |> render("template.json", %{template: template})

          {:else, template} ->
            error =
              case String.valid?(template) do
                false -> extract_changeset_error(template)
                true -> template
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, TemplateErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TemplateErrorHelper.error_message(:unauthorized))
    end
  end
end
