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

  def render("template.json", %{template: template}) do
    %{
      # name: "hello",
      name: template.name,
      uuid: template.uuid,
      # pages: template.pages
    }
  end
end
