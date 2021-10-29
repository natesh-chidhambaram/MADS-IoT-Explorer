defmodule AcqdatApi.Reports.Templates do
  alias AcqdatCore.Reports.Model.Template, as: TemplateModel

  defdelegate get_by_id(template_id), to: TemplateModel

  # pagination params
  def get_all(_data) do
    TemplateModel.get_all()
  end

  def create(attrs) do
    attrs
    |> template_create_attrs
    |> TemplateModel.create()
  end

  def update(template, attrs) do
    attrs =
      attrs
      |> template_create_attrs

    TemplateModel.update(template, attrs)
  end

  defdelegate delete(template), to: TemplateModel

  defp template_create_attrs(%{name: name, type: type, pages: pages, uuid: uuid}) do
    %{name: name, type: type, pages: pages, uuid: uuid}
  end

end
