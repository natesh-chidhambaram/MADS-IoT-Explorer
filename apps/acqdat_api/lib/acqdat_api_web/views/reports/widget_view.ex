defmodule AcqdatApiWeb.Reports.WidgetView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.WidgetView


  def render("widgets.json", %{data: data}) do
    %{
      data: render_many(data, WidgetView, "widget_data.json")
    }
  end

  def render("widget_data.json",  %{widget: data}) do
    %{
      classification: data.classification,
      count: data.count,
      widgets: render_many(data.widgets, WidgetView, "widget_details.json")
    }
  end

  def render("widget_details.json", %{widget: widget}) do
    %{
      id: widget["id"],
      widget_type_id: widget["widget_type_id"],
      label: widget["label"],
      classification: widget["classification"],
      properties: widget["properties"],
      policies: widget["policies"],
      category: widget["category"],
      image_url: widget["image_url"],
      uuid: widget["uuid"]
    }
  end

end
