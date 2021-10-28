defmodule AcqdatApiWeb.Reports.TemplateView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Reports.TemplateView

  def render("index.json", %{templates: templates}) do
    %{
      greet: "hello templates",
      templates: render_many(templates, TemplateView, "template.json")
    }
  end

  def render("index.json", role) do
    %{
      greet: "hello only"
    }
  end

  def render("template.json", %{template: %{name: name, uuid: uuid, pages: pages} }) do
    # IO.inspect(pages, label: "pagess....")
    %{
      name: name,
      uuid: uuid,
      pages:  render_many(pages, TemplateView, "template_pages.json")
    }
  end

  def render("template_pages.json", %{template: %{page_number: page_number, elements: elements} }) do
    # IO.inspect(template, label: "template ss....")
    %{
      page_number: page_number,
      elements:  render_many(elements, TemplateView, "template_page_elements.json")
       }
  end

  def render("template_page_elements.json", element) do
    # IO.inspect(page, label: "page vs vs....")
    # IO.inspect(Map.from_struct(element), label: "visual_settings vs")
    IO.inspect(element.template.visual_settings, label: "element ")
    %{
      visual_settings: element.template.visual_settings,
      data_settings: element.template.data_settings
    }
  end

  # def render("template_pages.json", %{page: %{page_number: page_number} }) do
  #   # IO.inspect(pages, label: "pagess....")
  #   %{
  #     name: page_number
  #   }
  # end

end
