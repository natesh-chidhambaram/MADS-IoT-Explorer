defmodule AcqdatApiWeb.SensorTypeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ErrorView

  def render("sensor_type.json", manifest) do
    %{
      id: manifest.id,
      name: manifest.name,
      make: manifest.make,
      identifier: manifest.identifier
    }
  end

  def render("400.json", assigns) do
    ErrorView.render("400.json", assigns)
  end

  def render("404.json", assigns) do
    ErrorView.render("404.json", assigns)
  end
end
