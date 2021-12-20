defmodule AcqdatApi.DashboardManagement.Subpanel do
  alias AcqdatCore.Model.DashboardManagement.Subpanel, as: SubpanelModel
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel
  import AcqdatApiWeb.Helpers

  defdelegate get_with_widgets(subpanel_uuid), to: SubpanelModel
  defdelegate update(subpanel, data), to: SubpanelModel
  defdelegate delete(panel), to: SubpanelModel

  def get_all_with_widgets(%{panel_id: panel_id}) do
    case SubpanelModel.get_all_subpanels(panel_id) do
      {:ok, subpanels} -> {:ok, subpanels}
      {:error, reason} -> {:error, reason}
    end
  end

  def create(attrs) do
    %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      panel_id: panel_id,
      settings: settings,
      filter_metadata: filter_metadata,
      widget_layouts: widget_layouts,
      icon: icon
    } = attrs

    panel_params = %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      panel_id: panel_id,
      settings: settings,
      icon: icon,
      filter_metadata:
        filter_metadata ||
          %{from_date: from_date, to_date: DateTime.to_unix(DateTime.utc_now(), :millisecond)},
      widget_layouts: widget_layouts
    }

    verify_panel(SubpanelModel.create(panel_params))
  end

  defp verify_panel({:ok, panel}) do
    {:ok, panel}
  end

  defp verify_panel({:error, panel}) do
    {:error, %{error: extract_changeset_error(panel)}}
  end

  defp from_date do
    DateTime.to_unix(Timex.shift(DateTime.utc_now(), hours: -2), :millisecond)
  end
end
