defmodule AcqdatApiWeb.SensorTypeView do
  use AcqdatApiWeb, :view

  def render("sensor_type.json", manifest) do
    %{
      sensor_id: manifest.sensor_id,
      name: manifest.name,
      make: manifest.make,
      identifier: manifest.identifier
    }
  end
end
