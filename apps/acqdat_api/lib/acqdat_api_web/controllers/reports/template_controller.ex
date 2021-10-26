defmodule AcqdatApiWeb.Reports.TemplateController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers

  import AcqdatApiWeb.Validators.Reports.Template
  alias AcqdatCore.Reports.Model.Template, as: TemplateModel

  def index(conn, params) do
    changeset = verify_index_params(params)
    # TODO pagination
    {:ok, _data} = extract_changeset_data(changeset)
    # templates = TemplateModel.get_all()
    data = %{}

    conn
    |> put_status(200)
    |> render("index.json", data)
  end

  # def create(conn, params) do
  # end
end
