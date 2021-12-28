defmodule AcqdatApi.DashboardManagement.Subpanel do
  import AcqdatApiWeb.Helpers

  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel

  defdelegate get_with_widgets(subpanel_id), to: PanelModel
  defdelegate update(subpanel, data), to: PanelModel
  defdelegate delete(panel), to: PanelModel

  def get_all(%{panel_id: parent_id}) do
    case PanelModel.get_all_by_parent_id(parent_id) do
      [] -> {:error, "No subpanel for this panel"}
      subpanels -> {:ok, subpanels}
    end
  end

  def create(attrs) do
    subpanel_params = %{
      name: attrs.name,
      description: attrs.description,
      org_id: attrs.org_id,
      dashboard_id: attrs.dashboard_id,
      parent_id: attrs.panel_id,
      settings: attrs.settings,
      icon: attrs.icon,
      filter_metadata:
        attrs.filter_metadata ||
          %{from_date: from_date, to_date: DateTime.to_unix(DateTime.utc_now(), :millisecond)},
      widget_layouts: attrs.widget_layouts
    }

    verify_panel(PanelModel.create(subpanel_params))
  end

  defp verify_panel({:ok, subpanel}) do
    {:ok, subpanel}
  end

  defp verify_panel({:error, subpanel}) do
    {:error, %{error: extract_changeset_error(subpanel)}}
  end

  defp from_date do
    DateTime.to_unix(Timex.shift(DateTime.utc_now(), hours: -2), :millisecond)
  end
end
