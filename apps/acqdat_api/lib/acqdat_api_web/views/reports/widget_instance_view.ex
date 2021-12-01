defmodule AcqdatApiWeb.Reports.WidgetInstanceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.WidgetInstanceView

  def render("widget_instance_data.json", %{widget: data}) do
    %{
      classification: data.classification,
      count: data.count,
      widget_instances:
        render_many(data.widget_instances, WidgetInstanceView, "widget_mould_details.json")
    }
  end

  def render("show.json", %{widget_instance: widget_instance}) do
    %{
      id: widget_instance.id,
      label: widget_instance.label,
      uuid: widget_instance.uuid
    }
  end

  def render("widget_data.json", %{widget_instance: widget}) do
    %{
      id: widget.id,
      label: widget.label,
      series_data: render_many(widget.series_data, WidgetInstanceView, "series_data.json"),
      visual_properties: widget.visual_properties,
      series: widget.series
    }
  end

  def render("series_data.json", %{widget_instance: series}) do
    %{
      name: series.name,
      color: series.color,
      unit: series.unit,
      axes: render_many(series.axes, WidgetInstanceView, "axes.json")
    }
  end

  def render("axes.json", %{widget_instance: series}) do
    %{
      name: series.name,
      source_type: series.source_type,
      source_details: series.source_metadata
    }
  end

  def render("widget_data.json", %{}) do
    %{
      label: "not found"
    }
  end
end
