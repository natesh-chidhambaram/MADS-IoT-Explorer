defmodule AcqdatApiWeb.Reports.TemplateView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.TemplateView

  def render("index.json", %{templates: templates}) do
    %{
      templates: render_many(templates, TemplateView, "show.json")
    }
  end

  def render("show.json", %{
        template: %{name: name, id: id, uuid: uuid, type: type, pages: pages}
      }) do
    %{
      name: name,
      id: id,
      type: type,
      uuid: uuid,
      pages: render_many(pages, TemplateView, "template_pages.json")
    }
  end

  def render("template_pages.json", %{template: %{page_number: page_number, elements: elements}}) do
    %{
      page_number: page_number,
      elements: render_many(elements, TemplateView, "template_page_elements.json")
    }
  end

  def render("template_page_elements.json", %{
        template: %{
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
