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

    # # Here an alert rule is created from sensor parameters. These parameters
    # # will be passed to gateway for mapping the parameters so that once
    # # data dump is done we can have a parameter uuid mapped to gateway to
    # # generate an alert.
    # test "create alert", %{alert_rule: alert_rules, sensor: sensor} do
    #   {:ok, alert_rules} = AlertRules.create(alert_rules)
    #   gateway = setup_gateway(sensor)
    #   data_dump = dump_iot_data(gateway)
    #   DataParser.start_parsing(data_dump)
    #   # TODO: have added a small time out so worker processes release db
    #   # connection, else the test exits and db connection is removed.
    #   # Need to add a clean way to handle this.
    #   :timer.sleep(450)
    #   alert = List.first(Repo.all(AlertSchema))
    #   assert Map.has_key?(alert, :app)
    #   assert Map.has_key?(alert, :policy_name)
    #   assert Map.has_key?(alert, :rule_parameters)
    #   assert Map.has_key?(alert, :org_id)
    #   assert Map.has_key?(alert, :assignee_ids)
    #   assert Map.has_key?(alert, :communication_medium)
    #   assert Map.has_key?(alert, :creator_id)
    #   assert Map.has_key?(alert, :entity_id)
    #   assert Map.has_key?(alert, :entity_name)
    #   assert Map.has_key?(alert, :status)
    #   assert Map.has_key?(alert, :severity)
    #   assert alert.app == alert_rules.app
    #   assert alert.assignee_ids == alert_rules.assignee_ids
    #   assert alert.communication_medium == alert_rules.communication_medium
    #   assert alert.policy_module_name == alert_rules.policy_name
    #   assert alert.org_id == alert_rules.org_id
    #   assert alert.creator_id == alert_rules.creator_id
    #   assert alert.entity_id == alert_rules.entity_id
    #   assert alert.entity_name == alert_rules.entity
    #   assert alert.status == :un_resolved
    #   assert alert.severity == alert_rules.severity
    # end

    # test "alert not created when alert rule is disabled", %{
    #   alert_rule: alert_rules,
    #   sensor: sensor
    # } do
    #   alert_rules = Map.replace!(alert_rules, :status, "disable")
    #   AlertRules.create(alert_rules)
    #   gateway = setup_gateway(sensor)
    #   data_dump = dump_iot_data(gateway)
    #   DataParser.start_parsing(data_dump)
    #   # TODO: have added a small time out so worker processes release db
    #   # connection, else the test exits and db connection is removed.
    #   # Need to add a clean way to handle this.
    #   :timer.sleep(150)
    #   alert = List.first(Repo.all(AlertSchema))
    #   assert alert == nil
    # end
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
        }
      ],
      expression: "partial1 AND partial2",
      grouping_meta: %{
        module: "Elixir.AcqdatCore.EntityManagement.Schema.Grouping.TimeGrouping",
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
        module: "Elixir.AcqdatCore.EntityManagement.Schema.Grouping.TimeGrouping",
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
