defmodule AcqdatCore.Domain.Notification do
  @moduledoc """
  Exposes APIs to handle notification
  """

  alias AcqdatCore.Model.Sensor
  alias AcqdatCore.Model.SensorNotification, as: SNotify
  alias AcqdatCore.Notification.PolicyMap
  alias AcqdatCore.Mailer
  alias AcqdatCore.Mailer.NotificationEmail

  @doc """
  Handles notifications for a device.

  Queries for notification configs set for different sensors,
  and checks the data received against the rules set in the
  configuration. If, the data meets the criteria set, a notification
  is sent.

  ### TODO: Optimize function by reducing number of db calls, at present
    for every sensor of the device, a db call is being made, reduce it to
    one db call.
  """
  @spec handle_notification(params :: map) :: [{:error, String.t()}] | {:ok, String.t()}
  def handle_notification(params) do
    %{device: device, data: data} = params

    result_list =
      Enum.flat_map(data, fn {sensor, sensor_data} ->
        result = Sensor.get(%{device_id: device.id, name: sensor})
        process_sensor_data(result, sensor_data)
      end)

    result_list
    |> Enum.filter(fn {status, _value} ->
      status == :ok
    end)
    |> case do
      [] ->
        result_list

      message_list ->
        send_notification(device, message_list)
    end
  end

  defp process_sensor_data({:error, _data}, _sensor_data), do: [{:error, "sensor not found"}]

  defp process_sensor_data({:ok, sensor}, sensor_data) do
    sensor.id
    |> SNotify.get_by_sensor()
    |> apply_rules(sensor, sensor_data)
  end

  defp apply_rules(nil, _sensor, _), do: [{:error, "no rules set"}]
  defp apply_rules(%{alarm_status: false}, _sensor, _), do: [{:error, "alarm disabled"}]

  defp apply_rules(notification_config, sensor, data) do
    Enum.map(data, fn {key, value} ->
      apply_rule_sensor_value_key(sensor, notification_config, key, value)
    end)
  end

  defp apply_rule_sensor_value_key(sensor, notification_config, key, value) do
    rule_values = notification_config.rule_values
    {:ok, module} = PolicyMap.load(rule_values[key]["module"])
    preferences = rule_values[key]["preferences"]
    result = module.eligible?(preferences, value)

    if result do
      {:ok, %{"#{sensor.name}" => %{"#{key}" => value}}}
    else
      {:error, "not eligible"}
    end
  end

  defp send_notification(device, message_list) do
    {_, message_list} = Enum.unzip(message_list)

    device
    |> NotificationEmail.email(message_list)
    |> Mailer.deliver_now()

    {:ok, "notification_sent"}
  end
end
