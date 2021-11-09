defmodule AcqdatApi.Reports.Widget do
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel

  defdelegate get_all_by_classification_not_standard(opts), to: WidgetModel

  defdelegate get_by_filter(widget_id, params), to: WidgetInstanceModel
end
