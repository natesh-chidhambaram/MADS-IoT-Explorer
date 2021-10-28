defmodule AcqdatApiWeb.Reports.TemplateView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.TemplateView

  def render("show.json", %{template: %{name: name, id: id, uuid: uuid, pages: pages}}) do
    %{
      name: name,
      id: id,
      uuid: uuid,
      pages: render_many(pages, TemplateView, "template_pages.json")
    }
  end

  # use show.json on create as well as update
  # def render("create.json", %{template: %{name: name, id: id, uuid: uuid, pages: pages}}) do
  #   %{
  #     name: name,
  #     id: id,
  #     uuid: uuid,
  #     pages: render_many(pages, TemplateView, "template_pages.json")
  #   }
  # end

  def render("index.json", %{templates: templates}) do
    %{
      templates: render_many(templates, TemplateView, "template.json")
    }
  end

  def render("index.json", role) do
    %{
      greet: "hello only"
    }
  end

  def render("template.json", %{template: %{name: name, id: id, uuid: uuid, type: type, pages: pages}}) do
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

  def render("template_page_elements.json", element) do
    %{
      visual_settings: element.template.visual_settings,
      data_settings: element.template.data_settings
    }
  end

end
