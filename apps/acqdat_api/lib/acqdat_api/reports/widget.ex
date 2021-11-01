defmodule AcqdatApi.Reports.Widget do
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel

  defdelegate get_all_by_classification_not_standard(opts), to: WidgetModel
end
