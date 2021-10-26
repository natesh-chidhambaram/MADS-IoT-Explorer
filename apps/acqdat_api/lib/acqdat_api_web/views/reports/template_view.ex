defmodule AcqdatApiWeb.Reports.TemplateView do
  use AcqdatApiWeb, :view
  # alias AcqdatApiWeb.Reports.TemplateView

  def render("index.json", %{data: _data}) do
    %{
      greet: "hello data"
    }
  end

  def render("index.json", role) do
    %{
      greet: "hello only"
    }
  end
end
