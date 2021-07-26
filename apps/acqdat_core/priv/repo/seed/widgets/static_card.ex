defmodule AcqdatCore.Seed.Widgets.StaticCard do
  @moduledoc """
  Holds seeds for StaticCard widgets.
  """
  use AcqdatCore.Seed.Helpers.CustomCardUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.CustomCards

  @custom_card_key_widget_settings %{
    card: %{
      visual: %{
        card: [type: %{value: "static card"}, backgroundColor: %{}, fontColor: %{}],
        title: [text: %{}, align: %{}, fontSize: %{value: "15px"}, fontColor: %{value: "#495057"}],
        description: [text: %{}, fontSize: %{value: "14px"}, fontColor: %{value: "#212529"}, align: %{}],
        subtitle: [text: %{}, fontSize: %{value: "14px"}, fontColor: %{value: "#74788d"}, align: %{}]
      }
    }
  }

  @custom_card_value_settings %{
    card: %{
      visual_setting_values: %{
        title: %{text: "Smart Meter A"},
        description: %{text: "Smart Meter A"}
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
      label: "Static Card",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "cards",
      image_url: "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/static-card.png",
      category: ["card", "static_card"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %CustomCards{}),
      default_values: data
    }
  end
end
