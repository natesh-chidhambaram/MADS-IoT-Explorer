defmodule AcqdatCore.Alerts.Model.GroupingTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  use Bamboo.Test
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Alerts.Model.Grouping
  alias AcqdatCore.AlertMessage.Token
  alias AcqdatCore.Alerts.Model.Alert, as: AlertModel

  describe "create_alert/1 " do
    test "new alert with no hash present" do
      alert_rule = insert(:alert_rules)
      inserted_timestamp = DateTime.truncate(DateTime.utc_now(), :second)
      params = create_alert_params(alert_rule, inserted_timestamp)

      Grouping.create_alert(params)
      # check if email delivered
      assert_email_delivered_with(subject: "Alert")
    end

    test "alert with grouping hash present, grouping criteria unmet, alert sent" do
      inserted_timestamp = Timex.shift(DateTime.utc_now(), minutes: 10)

      grouping_meta = %{
        module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
        grouping_parameters: %{
          value: 5,
          unit: "minutes",
          previous_time: DateTime.utc_now()
        }
      }

      alert_rule = insert(:alert_rules)
      {:ok, _alert} = create_alert(alert_rule, grouping_meta)

      params = create_alert_params(alert_rule, inserted_timestamp)

      Grouping.create_alert(params)
      assert_email_delivered_with(subject: "Alert")
    end

    test "alert with grouping hash present, grouping criteria unmet" do
      inserted_timestamp = Timex.shift(DateTime.utc_now(), minutes: 4)

      grouping_meta = %{
        module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
        grouping_parameters: %{
          value: 5,
          unit: "minutes",
          previous_time: DateTime.utc_now()
        }
      }

      alert_rule = insert(:alert_rules)
      {:ok, _alert} = create_alert(alert_rule, grouping_meta)

      params = create_alert_params(alert_rule, inserted_timestamp)

      Grouping.create_alert(params)
      refute_email_delivered_with(subject: "Alert")
    end

    test "alert with grouping not required" do
      inserted_timestamp = Timex.shift(DateTime.utc_now(), minutes: 4)
      alert_rule = insert(:alert_rules)

      params =
        alert_rule
        |> create_alert_params(inserted_timestamp)
        |> Map.put(:grouping_meta, %{})

      Grouping.create_alert(params)
      assert_email_delivered_with(subject: "Alert")

      ## send another alert as grouping not needed
      Grouping.create_alert(params)
      assert_email_delivered_with(subject: "Alert")
    end
  end

  defp create_alert_params(alert_rule, inserted_timestamp) do
    alert_policy_meta = %{
      rule_uuid: alert_rule.uuid,
      parameter_uuid: alert_rule.entity_parameters.uuid
    }

    grouping_meta = %{
      module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
      grouping_parameters: %{
        value: 1,
        unit: "hours"
      }
    }

    [user1, user2] = alert_rule.recepient_ids

    %Token{
      name: alert_rule.rule_name,
      description: alert_rule.description,
      alert_policy_meta: alert_policy_meta,
      grouping_meta: grouping_meta,
      org_id: alert_rule.org_id,
      project_id: alert_rule.project_id,
      recipient_ids: [%{type: "user", id: user1}, %{type: "user", id: user2}],
      severity: alert_rule.severity,
      communication_medium: ["e-mail"],
      entity_name: alert_rule.entity,
      entity_id: alert_rule.entity_id,
      app: alert_rule.app,
      inserted_timestamp: inserted_timestamp,
      alert_log: %{
        parameter: alert_rule.entity_parameters.uuid,
        value: 25,
        project: "Project Marvel",
        sensor: "Soul Stone",
        asset: "Infinity Gauntlet"
      }
    }
  end

  defp create_alert(alert_rule, grouping_meta) do
    alert_policy_meta = %{
      rule_uuid: alert_rule.uuid,
      parameter_uuid: alert_rule.entity_parameters.uuid
    }

    [user1, user2] = alert_rule.recepient_ids

    hash_params =
      %{}
      |> Map.put(:alert_policy_meta, alert_policy_meta)
      |> Map.put(:app, alert_rule.app)
      |> Map.put(:entity_name, alert_rule.entity)
      |> Map.put(:entity_id, alert_rule.entity_id)
      |> Map.put(:org_id, alert_rule.org_id)

    grouping_hash = to_string(Murmur.hash_x64_128(hash_params))

    params = %{
      name: alert_rule.rule_name,
      description: alert_rule.description,
      alert_policy_meta: alert_policy_meta,
      grouping_meta: grouping_meta,
      grouping_hash: to_string(grouping_hash),
      org_id: alert_rule.org_id,
      project_id: alert_rule.project_id,
      recipient_ids: [%{type: "user", id: user1}, %{type: "user", id: user2}],
      severity: alert_rule.severity,
      communication_medium: alert_rule.communication_medium,
      entity_name: alert_rule.entity,
      entity_id: alert_rule.entity_id,
      app: alert_rule.app,
      status: "un_resolved"
    }

    AlertModel.create(params)
  end
end
