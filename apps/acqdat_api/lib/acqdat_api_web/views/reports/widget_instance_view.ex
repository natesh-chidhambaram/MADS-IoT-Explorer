defmodule AcqdatApiWeb.Reports.WidgetInstanceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.WidgetInstanceView

  # def render("widget_instances.json", %{data: data}) do
  #   %{
  #     data: render_many(data, WidgetInstanceView, "widget_instance_data.json")
  #   }
  # end

  def render("widget_instance_data.json", %{widget: data}) do
    %{
      classification: data.classification,
      count: data.count,
      widget_instances:
        render_many(data.widget_instances, WidgetInstanceView, "widget_mould_details.json")
    }
  end

  def render("show.json", %{widget: widget}) do
    %{
      id: widget.id,
      # widget_type_id: widget.widget_type_id,
      label: widget.label,
      # classification: widget.classification,
      # properties: widget.properties,
      # policies: widget.policies,
      # category: widget.category,
      # image_url: widget.image_url,
      uuid: widget.uuid
    }
  end

  def render("widget_data.json", %{}) do
    %{
      label: "mot found"
    }
  end

  def render("widget_data.json", %{widget_instance: widget_instance}) do
    %{
      id: widget_instance.id,
      label: widget_instance.label
    }
  end
end
