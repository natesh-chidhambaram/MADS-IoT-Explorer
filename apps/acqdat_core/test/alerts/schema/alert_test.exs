defmodule AcqdatCore.Alerts.Schema.AlertTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  alias AcqdatCore.Alerts.Schema.Alert

  describe "changeset/2" do
    test "returns a valid changeset" do
      params = %{
        name: "Test name",
        description: "Test description",
        policy_module_name: "Elixir.AcqdatCore.Alerts.Policies.RangeBased",
        policy_name: "Alert when data is outside a bounded range",
        app: "iot_manager",
        entity_name: "Gateway",
        entity_id: 1,
        communication_medium: ["email", "sms"],
        recepient_ids: [1, 2, 3],
        severity: "Low",
        status: "resolved",
        creator_id: 1,
        org_id: 1,
        rule_parameters: [
          %{
            name: "temperature",
            data_type: "float",
            entity_parameter_uuid: "abc",
            entity_parameter_name: "temperature",
            value: 34
          },
          %{
            name: "humidity",
            data_type: "float",
            entity_parameter_uuid: "abc",
            entity_parameter_name: "temperature",
            value: 34
          }
        ]
      }

      %{valid?: validity} = Alert.changeset(%Alert{}, params)
      assert validity
    end

    test "returns invalid if one or more required fields are missing" do
      params = %{
        description: "Test description",
        policy_name: "range_based",
        policy_module_name: "Elixir.AcqdatCore.RangeBased",
        app: "iot_manager",
        entity_name: "Gateway",
        entity_id: 1,
        communication_medium: ["email", "sms"],
        recepient_ids: [1, 2, 3],
        severity: "Low",
        status: "resolved",
        creator_id: 1,
        rule_parameters: [
          %{
            name: "temperature",
            data_type: "float",
            entity_parameter_uuid: "abc",
            entity_parameter_name: "temperature",
            value: "34.5"
          },
          %{
            name: "humidity",
            data_type: "float",
            entity_parameter_uuid: "abc",
            entity_parameter_name: "temperature",
            value: "34.5"
          }
        ]
      }

      %{valid?: validity} = changeset = Alert.changeset(%Alert{}, params)
      refute validity

      assert %{
               org_id: ["can't be blank"],
               name: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns invalid if one or more required fields of rule_parameters are missing" do
      params = %{
        name: "Test name",
        description: "Test description",
        policy_name: "range_based",
        policy_module_name: "Elixir.AcqdatCore.RangeBased",
        app: "iot_manager",
        entity_name: "Gateway",
        entity_id: 1,
        communication_medium: ["email", "sms"],
        recepient_ids: [1, 2, 3],
        severity: "Low",
        status: "resolved",
        creator_id: 1,
        org_id: 1,
        rule_parameters: [
          %{
            data_type: "float",
            entity_parameter_uuid: "abc",
            entity_parameter_name: "temperature",
            value: "34.5"
          }
        ]
      }

      %{valid?: validity} = changeset = Alert.changeset(%Alert{}, params)
      refute validity

      assert %{rule_parameters: [%{name: ["can't be blank"]}]} = errors_on(changeset)
    end
  end
end
