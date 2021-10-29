defmodule AcqdatCore.Reports.Model.TemplateInstance do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Reports.Schema.TemplateInstance

  def get_all() do
    from(template_instance in TemplateInstance)
    |> Repo.all()
  end

  def create(params) do
    changeset = TemplateInstance.changeset(%TemplateInstance{}, params)
    Repo.insert(changeset)
  end

  def update(template_instance, attrs) do
    changeset = TemplateInstance.update_changeset(template_instance, attrs)
    Repo.update(changeset)
  end

  def get_by_id(id) do
    case Repo.get(TemplateInstance, id) do
      nil -> {:error, "template_instance with this id not found"}
      template_instance -> {:ok, template_instance}
    end
  end

  def delete(template_instance) do
    Repo.delete(template_instance)
  end
end
