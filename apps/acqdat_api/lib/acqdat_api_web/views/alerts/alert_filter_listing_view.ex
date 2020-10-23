defmodule AcqdatApiWeb.Alerts.AlertFilterListingView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Alerts.AlertFilterListingView

  def render("apps.json", %{apps: apps}) do
    %{
      apps: apps
    }
  end

  def render("status.json", %{status: status}) do
    %{
      status: status
    }
  end

  def render("alert_rules.json", %{alert_rules: alert_rules}) do
    %{
      alert_rules: render_many(alert_rules.entries, AlertFilterListingView, "alert_rule.json")
    }
  end

  def render("alert_rule.json", %{alert_filter_listing: alert_rule}) do
    %{
      alert_rule: alert_rule.rule_name
    }
  end
end
