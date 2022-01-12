defmodule AcqdatCore.EntityManagement.Schema.AlertRulesTest do
  @moduledoc """
  Testing module for alert rules schema
  """
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Schema.EntityManagement.AlertRules
  import AcqdatCore.Support.Factory

  describe "changeset/2" do
    setup :setup_alert_rules

    test "returns a valid changeset", %{alert_rule: alert_rule} do
      %{valid?: validity} = AlertRules.changeset(%AlertRules{}, alert_rule)
      assert validity
    end

    test "returns invalid changeset for missing required params" do
      %{valid?: validity} = changeset = AlertRules.changeset(%AlertRules{}, %{})
      refute validity

      assert %{
               app: ["can't be blank"],
               communication_medium: ["can't be blank"],
               creator_id: ["can't be blank"],
               entity: ["can't be blank"],
               entity_id: ["can't be blank"],
               org_id: ["can't be blank"],
               recepient_ids: ["can't be blank"],
               severity: ["can't be blank"],
               status: ["can't be blank"],
               expression: ["can't be blank"],
               rule_name: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  def setup_alert_rules(_context) do
    sensor = insert(:sensor)
    [param1, _param2] = fetch_parameters(sensor.sensor_type.parameters)
    [user1, user2, user3] = insert_list(3, :user)

    alert_rule = %{
      entity: 1,
      entity_id: sensor.id,
      partials: [
        %{
          name: "partial1",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 10, upper_limit: 20}
        },
        %{
          name: "partial1",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 10, upper_limit: 20}
        }
      ],
      expression: "partial1",
      grouping_meta: %{
        module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
        grouping_parameters: %{
          value: 1,
          unit: "hours"
        }
      },
      rule_name: "Entity Management Alert Rule",
      uuid: UUID.uuid1(:hex),
      communication_medium: ["in-app", "sms", "e-mail"],
      slug: Slugger.slugify(random_string(12)),
      recepient_ids: [0, user1.id, user2.id],
      assignee_ids: [user3.id],
      severity: "Low",
      status: "enable",
      app: "entity_manager",
      project_id: sensor.project_id,
      org_id: sensor.org_id,
      creator_id: user1.id
    }

    [alert_rule: alert_rule]
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp fetch_parameters(parameters) do
    Enum.reduce(parameters, [], fn param, acc ->
      acc ++ [Map.from_struct(param)]
    end)
  end
end
