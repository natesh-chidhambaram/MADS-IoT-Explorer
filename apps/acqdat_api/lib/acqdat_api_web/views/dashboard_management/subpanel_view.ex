defmodule AcqdatApiWeb.DashboardManagement.SubpanelView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.SubpanelView
  # alias AcqdatApiWeb.DashboardManagement.WidgetInstanceView
  # alias AcqdatApiWeb.DashboardManagement.CommandWidgetView

  def render("subpanel.json", %{subpanel: subpanel}) do
    %{
      id: subpanel.id,
      name: subpanel.name,
      icon: subpanel.icon,
      description: subpanel.description,
      org_id: subpanel.org_id,
      dashboard_id: subpanel.dashboard_id,
      panel_id: subpanel.parent_id,
      slug: subpanel.slug,
      uuid: subpanel.uuid,
      settings: subpanel.settings,
      widget_layouts: subpanel.widget_layouts,
      filter_metadata: render_one(subpanel.filter_metadata, SubpanelView, "filter_metadata.json")
    }
  end

  def render("show.json", %{subpanel: subpanel}) do
    %{
      id: subpanel.id,
      name: subpanel.name,
      icon: subpanel.icon,
      uuid: subpanel.uuid,
      slug: subpanel.slug,
      description: subpanel.description,
      settings: subpanel.settings,
      org_id: subpanel.org_id,
      dashboard_id: subpanel.dashboard_id,
      panel_id: subpanel.parent_id,
      widget_layouts: subpanel.widget_layouts,
      filter_metadata: render_one(subpanel.filter_metadata, SubpanelView, "filter_metadata.json")
    }
  end

  def render("index.json", %{subpanels: subpanels}) do
    %{subpanels: render_many(subpanels, SubpanelView, "subpanel.json")}
  end

  def render("delete_all.json", %{message: message}) do
    %{status: message}
  end

  def render("filter_metadata.json", %{subpanel: metadata}) do
    %{
      id: metadata.id,
      from_date: metadata.from_date,
      to_date: metadata.to_date,
      aggregate_func: metadata.aggregate_func,
      group_interval: metadata.group_interval,
      group_interval_type: metadata.group_interval_type,
      last: metadata.last,
      type: metadata.type
    }
  end
end
