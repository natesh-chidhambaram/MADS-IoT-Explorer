defmodule AcqdatApiWeb.Reports.TemplateController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers

  import AcqdatApiWeb.Validators.Reports.Template
  alias AcqdatApiWeb.Reports.TemplateErrorHelper

  # alias AcqdatCore.Reports.Model.Template, as: TemplateModel
  alias AcqdatApi.Reports.Templates

  def index(conn, params) do
    changeset = verify_index_params(params)

    IO.inspect(extract_changeset_data(changeset), label: "extract_changeset_data(changeset) ")


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

    {:ok, dataa} = extract_changeset_data(changeset)
    IO.inspect(dataa, label: "extract_changeset_dataa ....#####")

    with {:extract, {:ok, data} = extract_changeset_data(changeset)},
         {:create, {:ok, template}} <- {:create, Templates.create(data)} do
      conn
      |> put_status(200)
      |> render("create.json", %{template: template})
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, message}} ->
        send_error(conn, 400, message.error)
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
end
