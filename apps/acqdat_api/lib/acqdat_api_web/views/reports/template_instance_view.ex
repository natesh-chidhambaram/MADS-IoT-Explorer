defmodule AcqdatApiWeb.Reports.TemplateInstanceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.TemplateInstanceView

  def render("show.json", %{template_instance: %{name: name, id: id, uuid: uuid, pages: pages}}) do
    %{
      name: name,
      id: id,
      uuid: uuid,
      pages: render_many(pages, TemplateInstanceView, "template_instance_pages.json")
    }
  end

  def render("index.json", %{template_instances: template_instances}) do
    %{
      template_instances: render_many(template_instances, TemplateInstanceView, "template_instance.json")
    }
  end

  def render("index.json", role) do
    %{
      greet: "hello only"
    }
  end

  def render("template_instance.json", %{
        template_instance: %{name: name, id: id, uuid: uuid, type: type, pages: pages}
      }) do
    %{
      name: name,
      id: id,
      type: type,
      uuid: uuid,
      pages: render_many(pages, TemplateInstanceView, "template_instance_pages.json")
    }
  end

  def render("template_instance_pages.json", %{template_instance: %{page_number: page_number, elements: elements}}) do
    %{
      page_number: page_number,
      elements: render_many(elements, TemplateInstanceView, "template_instance_page_elements.json")
    }
  end

  def render("template_instance_page_elements.json", element) do
    %{
      visual_settings: element.template_instance.visual_settings,
      data_settings: element.template_instance.data_settings
    }
  end
end
