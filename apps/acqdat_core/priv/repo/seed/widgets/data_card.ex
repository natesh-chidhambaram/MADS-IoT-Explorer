defmodule AcqdatCore.Seed.Widgets.DataCard do
  @moduledoc """
  Holds seeds for DataCard widgets.
  """
  use AcqdatCore.Seed.Helpers.CustomCardUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.CustomCards

  @custom_card_key_widget_settings %{
    card: %{
      visual: %{
        card: [type: %{value: "data card"}, backgroundColor: %{}, fontColor: %{}],
        title: [text: %{}, align: %{value: ["left", "right", "center", "top", "bottom"]}, fontSize: %{value: "15px"}, fontColor: %{value: "#495057"}],
        unit: [text: %{}, align: %{}],
        image: [url: %{}, align: %{value: ["left", "right", "center", "top", "bottom"]}]
      },
      data: %{
        series: %{
          data_type: :object,
          value: %{},
          properties: %{
            multiple: %{data_type: :boolean, value: %{data: false}, properties: %{}}
          }
        },
        axes: %{
          data_type: :object,
          value: %{},
          properties: %{
            multiple: %{data_type: :boolean, value: %{data: false}, properties: %{}},
            y: %{data_type: :list, value: %{}, properties: %{}}
          }
        }
      }
    }
  }

  @custom_card_value_settings %{
    card: %{
      visual_setting_values: %{
        title: %{text: "temp"}
      },
      data_settings_values: %{
        series: [
          %{
            data: [%{y: 2}]
          }
        ]
     }
    }
  }

  def seed() do
    widget_type = WidgetHelpers.find_or_create_widget_type("CustomCards")
    seed_widgets(widget_type)
  end

  def seed_widgets(widget_type) do
    @custom_card_key_widget_settings
    |> Enum.map(fn {key, widget_settings} ->
      set_widget_data(key, widget_settings, @custom_card_value_settings[key],
        widget_type)
    end)
    |> Enum.each(fn data ->
      Repo.insert!(data)
    end)
  end

  def set_widget_data(_key, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "Data Card",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "cards",
      image_url: "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/data-card.png",
      category: ["card", "data_card"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %CustomCards{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %CustomCards{}),
      default_values: data
    }
  end

end
