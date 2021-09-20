defmodule AcqdatCore.Alerts.AlertCreation do
  @moduledoc """
  Contains logic of creation of an alert from alert rule.
  This module will receive data in object from data parser which will contain ids and the respective parameters
  to be stored. Example:-
  %{
    25 ->
      [
        %{
          parameter_uuid: uuid1,
          value: value1
        },
        %{
          parameter_uuid: uuid2,
          value: value2
        }
      ]
  }
  25 is the entity id and will be used to check alert rule existence for this id
  and parameter and it's valus is the one which will be used detect rule eligibility.
  """

  alias AcqdatCore.Alerts.Model.AlertRules
  alias AcqdatCore.Alerts.Server
  alias Notifications
  alias AcqdatCore.AlertMessage.Token
  alias AcqdatCore.Alerts.Model.Grouping
  alias AcqdatCore.Model.EntityManagement.Sensor

  @doc """
  For calling server for starting out alert creation
  """
  def gateway_alert(data) do
    GenServer.cast(Server, {:gateway_alert, data})
  end

  def sensor_alert(data) do
    GenServer.cast(Server, {:sensor_alert, data})
  end

  @doc """
  Receives data from dataparser module and for each entity ID will check if an
  alert rule exists or not.

  The data format received from the parser module is with sensor_id/gateway_id keys
  and list of parameter values.
  The example below is with sensor_id keys.

  ## Example
      %{
        264 => [
          %{
            data_type: "integer",
            name: "Sensor Type1 params2",
            uuid: "9b8386b610f011ec913d482ae331d1eb",
            value: 22
          },
          %{
            data_type: "integer",
            name: "Sensor Type1 params1",
            uuid: "9b8374d210f011ecb475482ae331d1eb",
            value: 20
          }
        ],
        265 => [
          %{
            data_type: "integer",
            name: "Sensor Type2 params3",
            uuid: "9b83973210f011ec8852482ae331d1eb",
            value: 23
          },
          %{
            data_type: "integer",
            name: "Sensor Type2 params4",
            uuid: "9b83a8f810f011ec8e7e482ae331d1eb",
            value: 24
          }
        ]
      }
  """
  def traverse_ids(data, "sensor") do
    Task.Supervisor.start_child(
      AlertGroupingSupervisor,
      fn ->
        Enum.each(data, fn {sensor_id, parameters} ->
          sensor_id
          |> check_alert_rule("sensor")
          |> case do
            nil -> :no_reply
            alert_rules -> check_parameter(alert_rules, parameters, sensor_id, "sensor")
          end
        end)
      end
    )
  end

  # Receives data from dataparser module and for each entity ID will check if a alert rule exist or not.
  def traverse_ids(data, "gateway") do
    Enum.each(data, fn {gateway_id, parameters} ->
      check_alert_rule(gateway_id, "gateway")
      |> case do
        nil -> :no_reply
        alert_rule -> check_parameter(alert_rule, parameters, gateway_id, "gateway")
      end
    end)
  end

  # Check for the availability of alert rule for that specific entity
  defp check_alert_rule(entity_id, entity) do
    AlertRules.check_rule(entity_id, entity)
  end

  # Check for the parameter of an entity if that parameter is a valid parameter
  # for which alert rule is created.
  # TODO: Instead of loading context here it should be sent from the caller.
  defp check_parameter(alert_rules, parameters, entity_id, "sensor") do
    {:ok, sensor} = Sensor.get(entity_id, [:project])
    context = prepare_context(sensor)

    Enum.each(parameters, fn parameter ->
      alert_rules
      |> Stream.filter(fn
        alert_rule -> alert_rule.entity_parameters.uuid == parameter.uuid
      end)
      |> Enum.each(fn alert_rule ->
        check_eligibility(parameter, alert_rule, context)
      end)
    end)
  end

  defp check_parameter(alert_rules, parameters, _entity_id, "gateway") do
    Enum.each(parameters, fn parameter ->
      alert_rules
      |> Stream.filter(fn
        alert_rule -> alert_rule.entity_parameters.uuid == parameter.uuid
      end)
      |> Enum.each(fn alert_rule ->
        check_eligibility(parameter, alert_rule, %{})
      end)
    end)
  end

  # check the eligibility of that parameter with the given policy
  defp check_eligibility(parameter, alert_rule, context) do
    case alert_rule.policy_name.eligible?(alert_rule.rule_parameters, parameter.value) do
      true ->
        :noreply

      false ->
        alert_rule
        |> data_manifest(parameter, context)
        |> Grouping.create_alert()
    end
  end

  # Create alert token with all the valid parameters
  defp data_manifest(alert_rule, parameter, context) do
    %Token{
      name: alert_rule.rule_name,
      description: format_description(alert_rule, parameter, context),
      alert_policy_meta: %{
        rule_uuid: alert_rule.uuid,
        parameter_uuid: parameter.uuid
      },
      grouping_meta: %{
        module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
        grouping_parameters: %{
          value: 1,
          unit: "hours"
        }
      },
      org_id: alert_rule.org_id,
      project_id: alert_rule.project_id,
      recipient_ids: format_recipient_ids(alert_rule.recepient_ids),
      severity: alert_rule.severity,
      communication_medium: alert_rule.communication_medium,
      entity_name: alert_rule.entity,
      entity_id: alert_rule.entity_id,
      # TODO: take a look into this, should contain sensor, asset and value of the
      # parameter
      alert_log: %{
        sensor_name: context.sensor_name,
        project_name: context.project_name,
        parameter: parameter.name,
        value: parameter.value
      },
      app: alert_rule.app,
      inserted_timestamp: DateTime.truncate(DateTime.utc_now(), :second),
      alert_metadata: parameter
    }
  end

  defp format_recipient_ids(recipient_ids) do
    Enum.map(recipient_ids, fn id ->
      %{type: "user", id: id}
    end)
  end

  defp format_description(alert_rule, parameter, context) do
    message = """
      Alert for parameter #{parameter.name} for sensor #{context.sensor_name}
      under the project #{context.project_name}
    """

    alert_description =
      if alert_rule.description != nil do
        alert_rule.description
      else
        ""
      end

    alert_description <> " " <> message
  end

  defp prepare_context(sensor) do
    %{
      sensor_name: sensor.name,
      project_name: sensor.project.name
    }
  end
end
