defmodule AcqdatCore.EntityManagement.AlertCreationTest do
  @moduledoc """
  Alert creation logics will be tested here
  """
  use ExUnit.Case, async: false
  use AcqdatCore.DataCase
  use AcqdatIotWeb.ConnCase
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel
  alias AcqdatCore.Model.EntityManagement.AlertRules
  alias AcqdatCore.Schema.EntityManagement.AlertRules, as: AlertSchema
  alias AcqdatCore.Schema.IotManager.GatewayDataDump
  alias AcqdatCore.IotManager.DataParser
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory
  alias AcqdatCore.EntityManagement.AlertCreation

  describe "create/1" do
    setup :setup_alert_rules

    test "alert creation for sensor", context do
      %{sensor: sensor, alert_rule_1: alert_rule_1, alert_rule_2: alert_rule_2} = context
      AlertRules.create(alert_rule_1)
      AlertRules.create(alert_rule_2)
      parameters = sensor.sensor_type.parameters

      parameters =
        Enum.map(parameters, fn parameter ->
          %{name: parameter.name, uuid: parameter.uuid, data_type: parameter.data_type, value: 15}
        end)

      data = Map.put(%{}, sensor.id, parameters)
      AlertCreation.traverse_ids(data, "Sensor")
      :timer.sleep(3000)
    end
  end

  def setup_alert_rules(_context) do
    sensor = insert(:sensor)
    [param1, param2] = fetch_parameters(sensor.sensor_type.parameters)
    [user1, user2, user3] = insert_list(3, :user)

    alert_rule_1 = %{
      entity: 1,
      description: "Alert Rule for sensor 1",
      entity_id: sensor.id,
      partials: [
        %{
          name: "partial1",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 10, upper_limit: 16}
        },
        %{
          name: "partial2",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param2,
          rule_parameters: %{lower_limit: 14, upper_limit: 20}
        },
        %{
          name: "partial9",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param2,
          rule_parameters: %{lower_limit: 16, upper_limit: 20}
        },
        %{
          name: "partial3",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.LowerThreshold",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 10}
        },
        %{
          name: "partial4",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.LowerThreshold",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 15}
        },
        %{
          name: "partial5",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.LowerThreshold",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 16}
        },
        %{
          name: "partial6",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.UpperThreshold",
          entity_parameters: param1,
          rule_parameters: %{upper_limit: 10}
        },
        %{
          name: "partial7",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.UpperThreshold",
          entity_parameters: param1,
          rule_parameters: %{upper_limit: 15}
        },
        %{
          name: "partial8",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.UpperThreshold",
          entity_parameters: param1,
          rule_parameters: %{upper_limit: 16}
        }
      ],
      expression:
        "partial1 and partial2 or partial3 and partial4 or partial5 or partial5 and partial6 or partial7 and partial8 and partial9",
      grouping_meta: %{
        module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
        grouping_parameters: %{
          value: 1,
          unit: "hours"
        }
      },
      rule_name: "Entity Management Alert Rule 1",
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

    alert_rule_2 = %{
      entity: 1,
      description: "Alert Rule for sensor 2",
      entity_id: sensor.id,
      partials: [
        %{
          name: "partial1",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param1,
          rule_parameters: %{lower_limit: 10, upper_limit: 20}
        },
        %{
          name: "partial2",
          policy_name: "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased",
          entity_parameters: param2,
          rule_parameters: %{lower_limit: 10, upper_limit: 20}
        }
      ],
      expression: "partial1 OR partial2",
      grouping_meta: %{
        module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
        grouping_parameters: %{
          value: 1,
          unit: "hours"
        }
      },
      rule_name: "Entity Management Alert Rule 2",
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

    [alert_rule_1: alert_rule_1, alert_rule_2: alert_rule_2, sensor: sensor]
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
