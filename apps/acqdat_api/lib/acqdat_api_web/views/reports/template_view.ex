defmodule AcqdatApiWeb.Reports.TemplateView do
  use AcqdatApiWeb, :view
  # alias AcqdatApiWeb.Reports.TemplateView

  def render("index.json", %{templates: templates}) do
    %{
      greet: "hello templates",
      data: templates
    }
  end

  def render("index.json", role) do
    %{
      greet: "hello only"
    }
  end
end
