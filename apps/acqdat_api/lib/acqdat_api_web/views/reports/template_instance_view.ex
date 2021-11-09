defmodule AcqdatApiWeb.Reports.TemplateInstanceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.TemplateInstanceView

  def render("index.json", %{template_instances: template_instances}) do
    %{
      template_instances: render_many(template_instances, TemplateInstanceView, "show.json")
    }
  end

  def render("show.json", %{
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

  def render("template_instance_pages.json", %{
        template_instance: %{page_number: page_number, elements: elements}
      }) do
    %{
      page_number: page_number,
      elements:
        render_many(elements, TemplateInstanceView, "template_instance_page_elements.json")
    }
  end

  def render("template_instance_page_elements.json", %{
        template_instance: %{
          layout: layout,
          styles: styles,
          options: options,
          type: type,
          sub_type: sub_type,
          uid: uid
        }
      }) do
    %{
      layout: layout,
      styles: styles,
      options: options,
      type: type,
      sub_type: sub_type,
      uid: uid
    }
  end
end
