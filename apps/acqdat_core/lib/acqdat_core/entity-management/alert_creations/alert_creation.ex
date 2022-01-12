defmodule AcqdatCore.EntityManagement.AlertCreation do
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

  alias AcqdatCore.Model.EntityManagement.AlertRules
  alias AcqdatCore.EntityManagement.AlertCreation
  alias Notifications
  alias AcqdatCore.AlertMessage.Token
  alias AcqdatCore.EntityManagement.Model.Grouping
  alias AcqdatCore.Model.EntityManagement.Sensor
  use Broadway

  @entity_queue "entity_queue"
  @exchange "alert_exchange"

  @doc """
  Receives data from dataparser module and for each entity ID will check if an
  alert rule exists or not.

  The data format received from the parser module is with sensor_id keys
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

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: @entity_queue,
           declare: [durable: true],
           connection: [
             username: System.get_env("BROADWAY_CONN_USERNAME"),
             password: System.get_env("BROADWAY_CONN_PASSWORD"),
             host: System.get_env("BROADWAY_CONN_HOST")
           ],
           on_failure: :reject},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 10
        ]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    AlertCreation.traverse_ids(Jason.decode!(message.data), "Sensor")
    Broadway.Message.ack_immediately(message)
  end

  def sensor_alert(data) do
    AlertCreation.traverse_ids(data, "Sensor")
  end

  def traverse_ids(data, "Sensor") do
    Enum.each(data, fn {sensor_id, parameters} ->
      sensor_id
      |> check_alert_rule("Sensor")
      |> case do
        nil ->
          :no_reply

        alert_rules ->
          Enum.each(alert_rules, fn alert_rule ->
            alert_rule
            |> bifurcate_partials()
            |> check_parameter(parameters, sensor_id, "Sensor")
            |> evaluate_partials(alert_rule)
            |> case do
              true ->
                {:ok, sensor} = Sensor.get(sensor_id, [:project])
                context = prepare_context(sensor)

                Enum.each(parameters, fn parameter ->
                  alert_rule
                  |> data_manifest(parameter, context)
                  |> Grouping.create_alert()
                end)

              false ->
                :no_reply
            end
          end)
      end
    end)
  end

  # Check for the availability of alert rule for that specific entity
  defp check_alert_rule(entity_id, entity) do
    AlertRules.check_rule(entity_id, :Sensor)
  end

  defp evaluate_partials(partial_results, alert_rule) do
    results =
      Enum.reduce(partial_results, %{}, fn result, acc ->
        Map.merge(acc, result)
      end)

    expression =
      Enum.reduce(results, "", fn {key, value}, acc ->
        case acc do
          "" -> String.replace(alert_rule.expression, key, to_string(value))
          _ -> String.replace(acc, key, to_string(value))
        end
      end)

    case Code.eval_string(expression) do
      {true, []} -> true
      {false, []} -> false
      _ -> false
    end
  end

  # Check for the parameter of an entity if that parameter is a valid parameter
  # for which alert rule is created.
  # TODO: Instead of loading context here it should be sent from the caller.
  defp check_parameter(alert_rules, parameters, entity_id, "Sensor") do
    {:ok, sensor} = Sensor.get(entity_id, [:project])
    context = prepare_context(sensor)

    Enum.reduce(parameters, [], fn parameter, acc ->
      result =
        alert_rules
        |> Stream.filter(fn
          alert_rule ->
            alert_rule.entity_parameters.uuid == parameter["uuid"]
        end)
        |> Enum.reduce(%{}, fn alert_rule, acc ->
          Map.put_new(
            acc,
            alert_rule.partial_name,
            check_eligibility(parameter, alert_rule, context)
          )
        end)

      acc ++ [result]
    end)
  end

  defp bifurcate_partials(alert_rule) do
    Enum.reduce(alert_rule.partials, [], fn partial, acc ->
      acc ++
        [
          %{
            partial_name: partial.name,
            entity: 1,
            rule_name: alert_rule.rule_name,
            entity_id: alert_rule.entity_id,
            policy_name: partial.policy_name,
            entity_parameters: partial.entity_parameters,
            uuid: alert_rule.uuid,
            communication_medium: alert_rule.communication_medium,
            slug: alert_rule.slug,
            rule_parameters: partial.rule_parameters,
            recepient_ids: alert_rule.recepient_ids,
            assignee_ids: alert_rule.assignee_ids,
            policy_type: ["user"],
            severity: alert_rule.severity,
            status: alert_rule.status,
            app: alert_rule.app,
            project_id: alert_rule.project_id,
            org_id: alert_rule.org_id,
            creator_id: alert_rule.creator_id
          }
        ]
    end)
  end

  # check the eligibility of that parameter with the given policy
  defp check_eligibility(parameter, alert_rule, context) do
    case alert_rule.policy_name.eligible?(alert_rule.rule_parameters, parameter["value"]) do
      true ->
        true

      false ->
        false
    end
  end

  # Create alert token with all the valid parameters
  defp data_manifest(alert_rule, parameter, context) do
    entity =
      case is_atom(alert_rule.entity) do
        true -> to_string(alert_rule.entity)
        false -> alert_rule.entity
      end

    %Token{
      name: alert_rule.rule_name,
      description: format_description(alert_rule, parameter, context),
      alert_policy_meta: %{
        rule_uuid: alert_rule.uuid,
        parameter_uuid: parameter["uuid"]
      },
      grouping_meta: Map.from_struct(alert_rule.grouping_meta),
      org_id: alert_rule.org_id,
      project_id: alert_rule.project_id,
      recipient_ids: format_recipient_ids(alert_rule.recepient_ids),
      severity: alert_rule.severity,
      communication_medium: alert_rule.communication_medium,
      entity_name: entity,
      entity_id: alert_rule.entity_id,
      # TODO: take a look into this, should contain sensor, asset and value of the
      # parameter
      alert_log: %{
        sensor_name: context.sensor_name,
        project_name: context.project_name,
        parameter: parameter["name"],
        value: parameter["value"]
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
      Alert for parameter #{parameter["name"]} for sensor #{context.sensor_name}
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
