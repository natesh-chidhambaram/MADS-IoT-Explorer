defmodule AcqdatApi.Reports.WidgetMould do
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Model.DashboardManagement.ReportWidget, as: ReportWidgetModel

  defdelegate get_all_by_classification_not_standard(opts), to: WidgetModel

  defdelegate get_by_filter(widget_id, params), to: WidgetInstanceModel

  defdelegate create(params), to: ReportWidgetModel
end
