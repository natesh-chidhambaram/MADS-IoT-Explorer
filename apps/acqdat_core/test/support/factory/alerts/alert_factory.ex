defmodule AcqdatCore.Factory.Alerts do
  defmacro __using__(_opts) do
    quote do
      alias AcqdatCore.Alerts.Schema.AlertRules
      alias AcqdatCore.Alerts.Schema.Alert

      @moduledoc """
        Alert factory, will consist support schemas to be used in alert functionality testing
      """
      def alert_rules_factory() do
        sensor = insert(:sensor)
        [param1, param2] = fetch_parameters(sensor.sensor_type.parameters)
        [user1, user2, user3] = insert_list(3, :user)

        %AlertRules{
          rule_name: "Alert Rule for sensor",
          description: "An alert has been generated for the sensor",
          entity: "sensor",
          entity_id: sensor.id,
          policy_name: "Elixir.AcqdatCore.Alerts.Policies.RangeBased",
          entity_parameters: param1,
          uuid: UUID.uuid1(:hex),
          communication_medium: ["in-app", "sms", "e-mail"],
          slug: sequence(:alert_rule_name, &"AlertRule#{&1}"),
          rule_parameters: %{lower_limit: 10, upper_limit: 20},
          recepient_ids: [user1.id, user2.id],
          assignee_ids: [user3.id],
          policy_type: ["user"],
          severity: "Low",
          status: "enable",
          app: "iot_manager",
          project_id: sensor.project_id,
          org_id: sensor.org_id,
          creator_id: user1.id
        }
      end

      def alert_factory() do
        sensor = insert(:sensor)
        [param1, param2] = fetch_parameters(sensor.sensor_type.parameters)
        [user1, user2, user3] = insert_list(3, :user)

        %Alert{
          name: "Alert for sensor",
          description: "raises an alert when threshold is met",
          alert_policy_meta: %{},
          grouping_meta: %{},
          entity_name: "sensor",
          entity_id: sensor.id,
          communication_medium: ["in-app", "sms", "e-mail"],
          recipient_ids: [%{type: "user", id: user1.id}, %{type: "user", id: user2.id}],
          severity: "Low",
          status: "un_resolved",
          app: "iot_manager",
          project_id: sensor.project_id,
          org_id: sensor.org_id,
          alert_meta: %{}
        }
      end

      defp fetch_parameters(parameters) do
        Enum.reduce(parameters, [], fn param, acc ->
          acc ++ [Map.from_struct(param)]
        end)
      end
    end
  end
end
