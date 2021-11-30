defmodule AcqdatApi.Reports.WidgetInstance do
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Reports.Model.ReportWidget, as: ReportWidgetModel

  defdelegate get_by_filter(widget_id, params), to: ReportWidgetModel

  def create(attrs) do
    attrs
    |> Map.from_struct()
    |> ReportWidgetModel.create()
  end
end
