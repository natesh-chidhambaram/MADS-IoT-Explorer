defmodule AcqdatApiWeb.EntityManagement.AlertRulesView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.AlertRulesView
  alias AcqdatCore.Model.EntityManagement.AlertRules

  def render("alert_rules.json", %{alert_rules: alert_rules}) do
    {:ok, severity} = EntityAlertSeverityEnum.dump(alert_rules.severity)
    recepient_ids = AlertRules.send_alert(alert_rules)

    grouping_meta =
      case alert_rules.grouping_meta do
        nil -> nil
        _ -> Map.from_struct(alert_rules.grouping_meta)
      end

    %{
      app: alert_rules.app,
      rule_name: alert_rules.rule_name,
      org_id: alert_rules.org_id,
      expression: alert_rules.expression,
      partials: render_many(alert_rules.partials, AlertRulesView, "partials.json"),
      assignee_ids: alert_rules.assignee_ids,
      grouping_meta: grouping_meta,
      communication_medium: alert_rules.communication_medium,
      creator_id: alert_rules.creator_id,
      phone_numbers: alert_rules.phone_numbers,
      description: alert_rules.description,
      entity: alert_rules.entity,
      entity_id: alert_rules.entity_id,
      id: alert_rules.id,
      project_id: alert_rules.project_id,
      recepient_ids: render_many(recepient_ids, AlertRulesView, "recepient.json"),
      severity: severity,
      slug: alert_rules.slug,
      status: alert_rules.status,
      uuid: alert_rules.uuid,
      created_at: alert_rules.inserted_at
    }
  end

  def render("partials.json", %{alert_rules: partial}) do
    %{
      name: partial.name,
      policy_name: partial.policy_name,
      rule_parameters: partial.rule_parameters,
      entity_parameters: render_one(partial.entity_parameters, AlertRulesView, "parameter.json")
    }
  end

  def render("parameter.json", %{alert_rules: params}) do
    %{
      data_type: params.data_type,
      uuid: params.uuid,
      unit: params.unit,
      name: params.name
    }
  end

  def render("index.json", alert_rules) do
    %{
      alert_rules: render_many(alert_rules.entries, AlertRulesView, "alert_rules.json"),
      page_number: alert_rules.page_number,
      page_size: alert_rules.page_size,
      total_entries: alert_rules.total_entries,
      total_pages: alert_rules.total_pages
    }
  end

  def render("recepient.json", %{alert_rules: recepient}) do
    %{
      id: recepient.id,
      email: recepient.user_credentials.email
    }
  end

  def render("grouping_rules.json", %{grouping_rules: grouping_rules}) do
    %{
      grouping_rules: render_many(grouping_rules, AlertRulesView, "grouping_rule.json")
    }
  end

  def render("grouping_rule.json", %{alert_rules: alert_rules}) do
    %{
      rule_name: alert_rules.rule_name,
      rule_module: alert_rules,
      rule_preferences: alert_rules.rule_preferences
    }
  end

  def render("policies.json", %{policies: policies}) do
    %{
      policies: render_many(policies, AlertRulesView, "policy.json")
    }
  end

  def render("policy.json", %{alert_rules: policy}) do
    %{
      policy_name: policy.rule_name,
      rule_parameters: policy.rule_preferences,
      policy_module: policy
    }
  end
end
