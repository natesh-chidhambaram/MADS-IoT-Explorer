defmodule AcqdatApiWeb.Reports.WidgetMouldView do
    use AcqdatApiWeb, :view
    alias AcqdatApiWeb.Reports.WidgetMouldView

    def render("widgets.json", %{data: data}) do
      %{
        data: render_many(data, WidgetMouldView, "widget.json")
      }
    end

    def render("widget.json",  %{widget_mould: data}) do
      %{
        classification: data.classification,
        count: data.count,
        widgets: render_many(data.widgets, WidgetMouldView, "widget_mould_details.json")
      }
    end

    def render("widget_mould_details.json", %{widget_mould: widget}) do
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
