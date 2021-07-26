defmodule AcqdatCore.Seed.Widget do
  @moduledoc """
  Holds seeds for initial widgets.
  """
  alias AcqdatCore.Seed.Widgets.{Line, Area, Pie, Bar, LineTimeseries, AreaTimeseries, GaugeSeries, SolidGauge,
        StockSingleLine, DynamicCard, ImageCard, StaticCard, BasicColumn, StackedColumn, StockColumn, HeatMap, PivotTable,
        DataCard, PercentageCard, UserCard, TableTimeseries}
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel

  def seed() do
    #Don't change the sequence it is important that widgets seeds this way.
    Line.seed()
    Area.seed()
    Pie.seed()
    Bar.seed()
    LineTimeseries.seed()
    AreaTimeseries.seed()
    GaugeSeries.seed()
    SolidGauge.seed()
    StockSingleLine.seed()
    DynamicCard.seed()
    ImageCard.seed()
    StaticCard.seed()
    BasicColumn.seed()
    StackedColumn.seed()
    StockColumn.seed()
    HeatMap.seed()
    PivotTable.seed()
    DataCard.seed()
    PercentageCard.seed()
    UserCard.seed()
    TableTimeseries.seed()
    WidgetHelpers.seed_in_elastic()
  end

  def update_image_urls() do
    charts = %{
      "Area Range" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/area-range.png",
      "area" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/area.png",
      "bar" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/bar.png",
      "Basic Column" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/basic-column.png",
      "gauge" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/gauge-series.png",
      "Line Timeseries" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/line-timeseries.png",
      "line" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/line.png",
      "pie" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/pie.png",
      "solidgauge" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/solid-gauge.png",
      "Stacked Column" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/stacked-column.png",
      "Stock Single line series" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/stock-single-line.png",
      "Dynamic Card" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/dynamic-card.png",
      "Image Card" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/image-card.png",
      "Static Card" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/static-card.png",
      "Stock Column" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/stock-column.png",
      "HeatMap" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/heat-map.png",
      "Data Card" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/data-card.png",
      "Percentage Card" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/percentage-card.png",
      "User Card" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/user-card.png",
      "Table Timeseries" => "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/table-timeseries.png"
    }

    Enum.each(charts, fn {label, image} ->
      case WidgetModel.get_by_label(label) do
        {:ok, widget} ->
          WidgetModel.update(widget, %{image_url: image})
        _ ->
          label
      end
    end)
  end

  def update_classifications() do
    Repo.transaction(fn ->
      card_widgets = ["Image Card", "Static Card", "Dynamic Card", "Data Card", "Percentage Card", "User Card"]
      update_classifications_of_widgets(card_widgets, "cards")

      gauge_widgets = ["solidgauge", "gauge"]
      update_classifications_of_widgets(gauge_widgets, "gauge")

      pie_widget = ["pie"]
      update_classifications_of_widgets(pie_widget, "standard")

      update_classifications_of_widgets(["Table Timeseries"], "timeseries")
    end)
  end

  def update_visual_settings() do
    charts = %{
      "Area Range" => {AreaTimeseries, :area},
      "area" => {Area, :area},
      "bar" => {Bar, :bar},
      "Basic Column" => {BasicColumn, :column},
      "gauge" => {GaugeSeries, :gauge},
      "Line Timeseries" => {LineTimeseries, :line},
      "line" => {Line, :line},
      "pie" => {Pie, :pie},
      "solidgauge" => {SolidGauge, :solidgauge},
      "Stacked Column" => {StackedColumn, :column},
      "Stock Single line series" => {StockSingleLine, :line},
      "Dynamic Card" => {DynamicCard, :card},
      "Image Card" => {ImageCard, :card},
      "Static Card" => {StaticCard, :card},
      "Stock Column" => {StockColumn, :column},
      "HeatMap" => {HeatMap, :heat_map},
      "Data Card" => {DataCard, :card},
      "Percentage Card" => {PercentageCard, :card},
      "User Card" => {UserCard, :card},
      "Table Timeseries" => {TableTimeseries, :card}
    }

    Enum.each(charts, fn {label, value} ->
      {module, widget_key} = value
      module.update_visual_settings(label, widget_key)
    end)
  end

  def update_data_settings() do
    chart_mappings = %{
      "Stock Single line series" => {StockSingleLine, :line},
      "solidgauge" => {SolidGauge, :solidgauge},
      "gauge" => {GaugeSeries, :gauge}
    }

    Enum.each(chart_mappings, fn {label, value} ->
      {module, widget_key} = value
      module.update_data_settings(label, widget_key)
    end)
  end

  defp update_classifications_of_widgets(widgets, classification) do
    Enum.each(widgets, fn name ->
      case WidgetModel.get_by_label(name) do
        {:ok, widget} ->
          WidgetModel.update(widget, %{classification: classification})
        _ ->
          name
      end
    end)
  end
end
