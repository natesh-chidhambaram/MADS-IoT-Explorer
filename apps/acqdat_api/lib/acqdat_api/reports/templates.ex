defmodule AcqdatApi.Reports.Templates do
  # alias AcqdatCore.Reports.Templates
  alias AcqdatCore.Reports.Model.Template, as: TemplateModel

  defdelegate get_by_id(template_id), to: TemplateModel

  def get_all(data) do
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

  def delete(template) do
    TemplateModel.delete(template)
  end

  defp template_create_attrs(%{name: name, type: type, pages: pages, uuid: uuid}) do
    %{name: name, type: type, pages: pages, uuid: uuid}
  end

  def create_dummy() do
    dummy_params = %{
      name: "bundi",
      uuid: "123",
      pages: [
        %{
          page_number: 2,
          elements: [
            %{
              visual_settings: %{color: "red", font_size: 12}
            }
          ]
        },
        %{
          page_number: 1,
          elements: [
            %{
              visual_settings: %{color: "blue", font_size: 15, padding: 6}
            }
          ]
        }
      ]
    }

    TemplateModel.create(dummy_params)
  end
end
