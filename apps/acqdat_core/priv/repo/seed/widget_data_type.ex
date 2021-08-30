defmodule AcqdatCore.Seed.WidgetDataType do
  alias AcqdatCore.Widgets.Schema.Widget
  alias AcqdatCore.Repo
  import Ecto.Query

def seed() do
  widget_data_type = %{
    "line" => ["integer", "float"],
    "area" => ["integer", "float"],
    "pie" => ["integer", "float"],
    "bar" => ["integer", "float"],
    "Line Timeseries" => ["integer", "float"],
    "Area Range" => ["integer", "float"],
    "gauge" => ["integer", "float"],
    "HeatMap" => ["integer", "float"],
    "solidgauge" => ["integer", "float"],
    "PivotTable" => ["integer", "float", "string", "boolean", "datetime"],
    "Stock Single line series" => ["integer", "float"],
    "Dynamic Card" => ["integer", "float", "string", "boolean", "datetime"],
    "Image Card" => ["string"],
    "Static Card" => ["integer", "float", "string", "boolean", "datetime"],
    "Basic Column" => ["integer", "float"],
    "Stacked Column" => ["integer", "float"],
     "Stock Column" => ["integer", "float"],
     "User Card" => ["string"],
     "Table Timeseries" => ["integer", "float"],
     "Data Card" => ["integer", "float"],
     "Percentage Card" => ["integer", "float"]
  }
  widgets = Repo.all(Widget)

  Enum.each(widgets, fn widget ->
    changeset = Widget.update_changeset(widget, %{widget_data_type: widget_data_type[widget.label]})
    Repo.update(changeset)
  end)
end
end
