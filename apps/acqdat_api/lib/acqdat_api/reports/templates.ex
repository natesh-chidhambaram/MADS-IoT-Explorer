defmodule AcqdatApi.Reports.Templates do
  # alias AcqdatCore.Reports.Templates
  alias AcqdatCore.Reports.Model.Template, as: TemplateModel

  # defdelegate get_all(data), to: TemplateModel

  def get_all(data) do
    TemplateModel.get_all()
  end

  def create(attrs) do
    # add current_user
    TemplateModel.create(attrs)
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
