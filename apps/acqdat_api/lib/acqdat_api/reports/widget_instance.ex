defmodule AcqdatApi.Reports.WidgetInstance do
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Reports.Model.ReportWidget, as: WidgetInstanceModel

  defdelegate get_by_filter(widget_id, params), to: WidgetInstanceModel
  defdelegate delete(widget_instance), to: WidgetInstanceModel
  defdelegate update(widget_instance, params), to: WidgetInstanceModel

  def create(attrs) do
    attrs
    |> Map.from_struct()
    |> WidgetInstanceModel.create()
  end
end
