defmodule AcqdatCore.Alerts.Model.AlertTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Alerts.Model.Alert, as: AlertModel

  describe "create/1 " do
    test "with valid params" do
      alert_rule = insert(:alert_rules)
      params = create_alert_params(alert_rule)

      {:ok, alert} = AlertModel.create(params)
      assert alert.name == alert_rule.rule_name
    end

    test "alert with duplicate grouping hash, returns error" do
      alert_rule = insert(:alert_rules)
      params = create_alert_params(alert_rule)
      # create an alert
      AlertModel.create(params)

      # create an alert which has same grouping hash because it's from the
      # same alert_policy_meta and combination of entity_name, entity_id, app
      # and org_id
      {:error, changeset} = AlertModel.create(params)

      assert %{
               grouping_hash: ["unqiue hash per alert should be generated"]
             } == errors_on(changeset)
    end

    test "alerts with no grouping" do
      alert_rule = insert(:alert_rules)
      params = create_alert_params(alert_rule)
      params = params |> Map.drop([:alert_policy_meta, :grouping_hash])

      # create an alert
      {result, alert1} = AlertModel.create(params)
      assert result == :ok

      # create another alert with same params as grouping not necessary
      {result, alert2} = AlertModel.create(params)
      assert result == :ok

      assert alert1.name == alert2.name
      assert alert1.entity_name == alert2.entity_name
    end

    test "with invalid params" do
      invalid_params = %{name: "Test name"}
      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 0

      {:error, _} = AlertModel.create(invalid_params)

      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 0
    end
  end

  describe "update/1 " do
    setup do
      alert_rule = insert(:alert_rules)
      params = create_alert_params(alert_rule)
      {:ok, alert} = AlertModel.create(params)
      [alert: alert, alert_rule: alert_rule]
    end

    test "grouping hash can't be updated", context do
      %{alert_rule: alert_rule, alert: alert} = context

      hash_params =
        %{}
        |> Map.put(:alert_policy_meta, alert_rule.entity)
        |> Map.put(:app, alert_rule.app)

      grouping_hash = to_string(Murmur.hash_x64_128(hash_params))
      update_params = %{grouping_hash: grouping_hash}

      {:ok, result} = AlertModel.update(alert, update_params)

      assert alert.grouping_hash == result.grouping_hash
      refute grouping_hash == result.grouping_hash
    end

    test "grouping meta related info", context do
      %{alert: alert} = context

      grouping_meta = %{
        module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
        grouping_parameters: %{
          value: 2,
          unit: "hours",
          previous_time: Timex.shift(DateTime.utc_now(), hours: 1)
        }
      }

      update_params = %{grouping_meta: grouping_meta}
      {:ok, result} = AlertModel.update(alert, update_params)
      assert result.grouping_meta != alert.grouping_meta
    end
  end

  describe "delete/1" do
    setup do
      alert_rule = insert(:alert_rules)
      params = create_alert_params(alert_rule)
      {:ok, alert} = AlertModel.create(params)
      [alert: alert]
    end

    test "with valid params", %{alert: alert} do
      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 1

      {:ok, _} = AlertModel.delete(alert)

      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 0
    end
  end

  describe "get_all/1" do
    setup do
      alert_rule = insert(:alert_rules)
      params = create_alert_params(alert_rule)
      {:ok, alert} = AlertModel.create(params)
      [alert: alert]
    end

    test "with valid params", %{alert: alert} do
      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 1

      first_alert = alerts.entries |> List.first()
      assert first_alert.name == alert.name
      assert first_alert.description == alert.description
    end
  end

  describe "get/1 " do
    setup do
      alert_rule = insert(:alert_rules)
      params = create_alert_params(alert_rule)
      {:ok, alert} = AlertModel.create(params)
      [alert: alert]
    end

    test "with valid id", %{alert: alert} do
      {:ok, first_alert} = AlertModel.get(alert.id)

      assert first_alert.name == alert.name
      assert first_alert.description == alert.description
    end

    test "with invalid id", %{alert: _} do
      {state, message} = AlertModel.get(12132)

      assert state == :error
      assert message == "Alert not found"
    end

    test "with grouping hash", %{alert: alert} do
      {:ok, result} = AlertModel.get(%{grouping_hash: alert.grouping_hash})
      assert result.name == alert.name
    end
  end

  defp create_alert_params(alert_rule) do
    alert_policy_meta = %{
      rule_uuid: alert_rule.uuid,
      parameter_uuid: alert_rule.entity_parameters.uuid
    }

    grouping_meta = %{
      module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
      grouping_parameters: %{
        value: 1,
        unit: "hours",
        previous_time: DateTime.utc_now()
      }
    }

    hash_params =
      %{}
      |> Map.put(:alert_policy_meta, alert_policy_meta)
      |> Map.put(:app, alert_rule.app)
      |> Map.put(:entity_name, alert_rule.entity)
      |> Map.put(:entity_id, alert_rule.entity_id)
      |> Map.put(:org_id, alert_rule.org_id)

    grouping_hash = to_string(Murmur.hash_x64_128(hash_params))

    %{
      name: alert_rule.rule_name,
      description: alert_rule.description,
      alert_policy_meta: alert_policy_meta,
      grouping_meta: grouping_meta,
      grouping_hash: to_string(grouping_hash),
      org_id: alert_rule.org_id,
      project_id: alert_rule.project_id,
      recipient_ids: [%{type: "user", id: 1}, %{type: "user", id: 2}, %{type: "user", id: 3}],
      severity: alert_rule.severity,
      communication_medium: alert_rule.communication_medium,
      entity_name: alert_rule.entity,
      entity_id: alert_rule.entity_id,
      app: alert_rule.app,
      status: "un_resolved"
    }
  end
end
