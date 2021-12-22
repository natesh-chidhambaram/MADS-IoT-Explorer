defmodule AcqdatApiWeb.DashboardManagement.PanelView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.PanelView
  alias AcqdatApiWeb.DashboardManagement.WidgetInstanceView
  alias AcqdatApiWeb.DashboardManagement.CommandWidgetView

  def render("delete_all.json", %{message: message}) do
    %{
      status: message
    }
  end

  def render("panel.json", %{panel: panel}) do
    %{
      id: panel.id,
      name: panel.name,
      icon: panel.icon,
      description: panel.description,
      org_id: panel.org_id,
      dashboard_id: panel.dashboard_id,
      slug: panel.slug,
      uuid: panel.uuid,
      settings: panel.settings,
      widget_layouts: panel.widget_layouts,
      filter_metadata: render_one(panel.filter_metadata, PanelView, "filter_metadata.json")
    }
  end

  def render("index.json", %{panels: panels}) do
    %{
      panels: render_many(panels, PanelView, "panel.json")
    }
  end

  def render("show.json", %{panel: panel}) do
    %{
      id: panel.id,
      name: panel.name,
      icon: panel.icon,
      description: panel.description,
      org_id: panel.org_id,
      dashboard_id: panel.dashboard_id,
      slug: panel.slug,
      uuid: panel.uuid,
      settings: panel.settings,
      widget_layouts: panel.widget_layouts,
      widgets: render_many(panel.widgets, WidgetInstanceView, "show_without_data.json"),
      command_widgets: render_many(panel.command_widgets, CommandWidgetView, "show.json"),
      filter_metadata: render_one(panel.filter_metadata, PanelView, "filter_metadata.json"),
      subpanels: render_many(panel.subpanels, PanelView, "subpanel.json")
    }
  end

  def render("subpanel.json", %{panel: subpanel}) do
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
      filter_metadata: render_one(subpanel.filter_metadata, PanelView, "filter_metadata.json")
    }
  end

  def render("filter_metadata.json", %{panel: metadata}) do
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
