defmodule AcqdatApi.Widgets.WidgetType do
  alias AcqdatCore.Model.Widgets.WidgetType, as: WidgetTypeModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      vendor: vendor,
      name: name,
      vendor_metadata: vendor_metadata,
      module: module
    } = params

    verify_widget_type(
      WidgetTypeModel.create(%{
        vendor: vendor,
        name: name,
        vendor_metadata: vendor_metadata,
        module: module
      })
    )
  end

  defp verify_widget_type({:ok, widget_type}) do
    {:ok,
     %{
       id: widget_type.id,
       vendor: widget_type.vendor,
       module: widget_type.module,
       name: widget_type.name,
       vendor_metadata: widget_type.vendor_metadata
     }}
  end

  defp verify_widget_type({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end
end
