defmodule AcqdatCore.EntityManagement.Schema.AlertRulesTest do
  @moduledoc """
  Testing module for alert rules schema
  """
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.AlertRules
  import AcqdatCore.Support.Factory

  describe "changeset/2" do
    setup :setup_alert_rules

    test "returns a valid changeset", %{alert_rule: alert_rule} do
      %{valid?: validity} = AlertRules.changeset(%AlertRules{}, alert_rule) |> Repo.insert()
      assert validity
    end
  end

  def setup_alert_rules(_context) do
    sensor = insert(:sensor)
    [param1, _param2] = fetch_parameters(sensor.sensor_type.parameters)
    [user1, user2, user3] = insert_list(3, :user)

    alert_rule = %{
      partials: [
        %{
          entity: 1,
          name: "partial1",
          entity_id: sensor.id,
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 10, upper_limit: 20}
        },
        %{
          entity: 1,
          name: "partial1",
          entity_id: sensor.id,
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 10, upper_limit: 20}
        }
      ],
      expression: "partial1",
      grouping_meta: %{
        module: "Elixir.AcqdatCore.EntityManagement.Schema.Grouping.TimeGrouping",
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
      app: "iot_manager",
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
