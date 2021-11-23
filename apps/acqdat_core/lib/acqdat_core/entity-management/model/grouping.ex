defmodule AcqdatCore.EntityManagement.Model.Grouping do
  @moduledoc """
  A module which takes care of the grouping logic for the alerts.

  Grouping is an important feature for alerts which avoids too many notifications
  being sent to a user for any event.

  All the alerts which are generated from the same entity(sensor, gateway, asset)
  for the same app and under same rules can be grouped together based on time interval
  or number of events.
  In order to deal with groupings a grouping hash is kept in the alerts object.
  The grouping hash is generated from the policy which generates an alert.
  An alert policy is an app specific rule that generates an alert.

  ## Grouping Queue
  All the alert messages published by an app are published to Grouping Queue.
  The grouping queue is maintained in Rabbitmq. A grouping queue is started
  per organisation.
  The Grouping Queue is a task queue with a number of workers.

  A worker will pull out a message from the queue and check if the current
  message is similar to any alert message that has been received previously.
  The similarity check is based on the grouping hash which will be generated
  from the `alert_policy_meta`.
  """

  # alias AcqdatCore.Alerts.Model.Alert
  # alias AcqdatCore.AlertMessage.Token
  # alias Ecto.Multi
  # alias AcqdatCore.Repo
  # require Logger

  # def create_alert(%Token{grouping_meta: grp_meta} = params) when grp_meta == %{} do
  #   alert_data = params |> Map.from_struct() |> Map.put(:status, "un_resolved")
  #   insert_and_notify(alert_data, params)
  # end

  # def create_alert(%Token{} = params) do
  #   hash = create_hash(params)
  #   grouping_hash = %{grouping_hash: hash}

  #   grouping_hash
  #   |> Alert.get()
  #   |> update_and_notify(params, hash)
  # end

  def list_grouping() do
    Enum.reduce(EntityAlertGroupingEnum.__enum_map__(), [], fn {key, value}, acc ->
      acc ++ [key]
    end)
  end

  ################### Pricvate Functions #############################

  # Note that we are working separately with alert and alert_event_logs because
  # we essentially want to work with one event log at the given time.
  # See `cast_assoc` and `put_assoc` in Ecto module for more info.
  # defp update_and_notify({:ok, alert}, params, _grouping_hash) do
  #   alert_update_params = prepare_update_params(params)

  #   Multi.new()
  #   |> Multi.run(:update_alert, fn _, _ ->
  #     Alert.update(alert, alert_update_params)
  #   end)
  #   |> Multi.run(:create_alert_log, fn _, %{update_alert: alert} ->
  #     alert_event_data = prepare_log_params(params, alert.id)
  #     Alert.create_alert_log(alert_event_data)
  #   end)
  #   |> Repo.transaction()
  #   |> case do
  #     {:ok, %{update_alert: new_alert, create_alert_log: log}} ->
  #       check_eligibility(new_alert, alert, params, log)

  #     {:error, failed_operation, failed_value, _changes_so_far} ->
  #       {:error, {failed_operation, failed_value}}
  #   end
  # end

  # defp update_and_notify({:error, _message}, params, grouping_hash) do
  #   alert_data = prepare_insert_params(params, grouping_hash)
  #   insert_and_notify(alert_data, params)
  # end

  # defp insert_and_notify(alert_data, params) do
  #   Multi.new()
  #   |> Multi.run(:create_alert, fn _, _ ->
  #     Alert.create(alert_data)
  #   end)
  #   |> Multi.run(:create_alert_log, fn _, %{create_alert: alert} ->
  #     alert_event_data = prepare_log_params(params, alert.id)
  #     Alert.create_alert_log(alert_event_data)
  #   end)
  #   |> Repo.transaction()
  #   |> case do
  #     {:ok, %{create_alert: alert, create_alert_log: log}} ->
  #       {:ok, {alert, log}}
  #       send_alert(alert, log)

  #     {:error, failed_operation, failed_value, _changes_so_far} ->
  #       Logger.error("#{inspect(failed_operation)}")
  #       Logger.error("#{inspect(failed_value)}")

  #       Logger.error("Alert sending failed",
  #         failed_operation: failed_operation,
  #         failed_value: failed_value
  #       )

  #       {:error, {failed_operation, failed_value}}
  #   end
  # end

  # defp create_hash(params) do
  #   hash_params =
  #     %{}
  #     |> Map.put(:alert_policy_meta, params.alert_policy_meta)
  #     |> Map.put(:app, params.app)
  #     |> Map.put(:entity_name, params.entity_name)
  #     |> Map.put(:entity_id, params.entity_id)
  #     |> Map.put(:org_id, params.org_id)

  #   to_string(Murmur.hash_x64_128(hash_params))
  # end

  # defp check_eligibility(new_alert, alert, params, log) do
  #   grouping = alert.grouping_meta

  #   if grouping.module.run_check?(grouping.grouping_parameters, params) do
  #     send_alert(new_alert, log)
  #   else
  #     :ok
  #   end
  # end

  # TODO: At present recipient ids are only for user hence the handling is only
  # for that, it needs to be changed for org and projects too later.
  # defp send_alert(alert, alert_log) do
  #   alert_log = Map.from_struct(alert_log)

  #   recipient_ids =
  #     Enum.map(alert.recipient_ids, fn recipient ->
  #       recipient.id
  #     end)

  #   app =
  #     Atom.to_string(alert.app)
  #     |> String.split("_")
  #     |> Enum.reduce([], fn x, acc -> acc ++ [String.capitalize(x)] end)
  #     |> Enum.reduce("", fn x, acc -> acc <> x <> " " end)
  #     |> String.trim_trailing(" ")

  #   alert_log =
  #     alert_log
  #     |> Map.put(:app, app)
  #     |> Map.put(:communication_medium, alert.communication_medium)
  #     |> Map.put(:recipient_ids, recipient_ids)

  #   Notifications.send_notifications(alert_log, "twilio")
  # end

  # TODO: optimize creating grouping_meta
  # defp prepare_insert_params(%Token{} = params, grouping_hash) do
  #   grouping_params =
  #     Map.put(params.grouping_meta.grouping_parameters, :previous_time, params.inserted_timestamp)

  #   grouping_meta = Map.put(params.grouping_meta, :grouping_parameters, grouping_params)

  #   alert_params = Map.from_struct(params)

  #   alert_params
  #   |> Map.put(:grouping_hash, grouping_hash)
  #   |> Map.put(:status, "un_resolved")
  #   |> Map.put(:grouping_meta, grouping_meta)
  # end

  # defp prepare_update_params(%Token{} = params) do
  #   grouping_params =
  #     Map.put(params.grouping_meta.grouping_parameters, :previous_time, params.inserted_timestamp)

  #   grouping_meta = Map.put(params.grouping_meta, :grouping_parameters, grouping_params)

  #   %{
  #     name: params.name,
  #     description: params.description,
  #     communication_medium: params.communication_medium,
  #     status: "un_resolved",
  #     severity: params.severity,
  #     grouping_meta: grouping_meta
  #   }
  # end

  # defp prepare_log_params(%Token{} = params, alert_id) do
  #   %{
  #     inserted_timestamp: params.inserted_timestamp,
  #     name: params.name,
  #     description: params.description,
  #     severity: params.severity,
  #     alert_metadata: params.alert_log,
  #     alert_id: alert_id
  #   }
  # end
end
