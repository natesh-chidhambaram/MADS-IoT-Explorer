defmodule AcqdatApiWeb.Widgets.WidgetTypeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Widgets.WidgetTypeView

  def render("widget_type.json", %{widget_type: widget_type}) do
    %{
      id: widget_type.id,
      name: widget_type.name,
      vendor: widget_type.vendor,
      module: widget_type.module,
      vendor_metadata: widget_type.vendor_metadata
    }
  end

  def render("index.json", widget_type) do
    %{
      widget_type: render_many(widget_type.entries, WidgetTypeView, "widget_type.json"),
      page_number: widget_type.page_number,
      page_size: widget_type.page_size,
      total_entries: widget_type.total_entries,
      total_pages: widget_type.total_pages
    }
  end
end
