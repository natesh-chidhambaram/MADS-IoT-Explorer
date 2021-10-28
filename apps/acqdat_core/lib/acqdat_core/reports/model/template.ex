defmodule AcqdatCore.Reports.Model.Template do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Reports.Schema.Template

  def get_all() do
    from(template in Template)
    |> Repo.all()
  end

  def create(params) do
    changeset = Template.changeset(%Template{}, params)
    Repo.insert(changeset)
  end

  def update(template, attrs) do
    changeset = Template.update_changeset(template, attrs)
    Repo.update(changeset)
  end

  # id or uuid?
  def get_by_id(id) do
    case Repo.get(Template, id) do
      nil -> {:error, "template with this id not found"}
      template -> {:ok, template}
    end
  end

end
