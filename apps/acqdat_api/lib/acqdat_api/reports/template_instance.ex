defmodule AcqdatApi.Reports.TemplateInstance do
  alias AcqdatCore.Reports.Model.TemplateInstance, as: TemplateInstanceModel

  defdelegate get_by_id(template_instance_id), to: TemplateInstanceModel

  def get_all(_data) do
    TemplateInstanceModel.get_all()
  end

  def create(attrs) do
    attrs
    |> template_instance_create_attrs
    |> TemplateInstanceModel.create()
  end

  def update(template_instance, attrs) do
    attrs =
      attrs
      |> template_instance_create_attrs

    TemplateInstanceModel.update(template_instance, attrs)
  end

  defdelegate delete(template), to: TemplateInstanceModel

  defp template_instance_create_attrs(%{name: name, type: type, pages: pages, org_id: org_id}) do
    %{name: name, type: type, pages: pages, org_id: org_id}
  end
end
