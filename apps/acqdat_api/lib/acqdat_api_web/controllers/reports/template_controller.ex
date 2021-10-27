defmodule AcqdatApiWeb.Reports.TemplateController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers

  import AcqdatApiWeb.Validators.Reports.Template

  # alias AcqdatCore.Reports.Model.Template, as: TemplateModel
  alias AcqdatApi.Reports.Templates

  def index(conn, params) do
    changeset = verify_index_params(params)
    # TODO pagination
    {:ok,  data} = extract_changeset_data(changeset)

    templates = Templates.get_all(data)
    resp_data = %{templates: templates}

    conn
    |> put_status(200)
    |> render("index.json", resp_data)
  end

  def show(conn, params) do

  end
  # def create(conn, params) do
  # end
end
