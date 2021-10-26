defmodule AcqdatCore.Reports.Schema.Template do
  use AcqdatCore.Schema

  schema("acqdat_reports_template") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string)

    embeds_many :pages, Pages, on_replace: :delete do
      field(:page_number, :string, null: false)

      embeds_many :elements, PageElements, on_replace: :delete do
        field(:visual_settings, {:array, :map})
        field(:data_settings, {:array, :map})
      end
    end
  end
end
