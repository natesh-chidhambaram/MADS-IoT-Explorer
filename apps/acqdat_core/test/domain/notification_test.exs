# defmodule AcqdatCore.Domain.NotificationTest do
#   use ExUnit.Case, async: true
#   use AcqdatCore.DataCase
#   import AcqdatCore.Support.Factory
#   alias AcqdatCore.Domain.Notification

#   @rule_values %{
#     "temp" => %{
#       "preferences" => %{"lower_limit" => 80, "upper_limit" => 100},
#       "module" => "Elixir.AcqdatCore.Schema.Notification.RangeBased"
#     },
#     "humid" => %{
#       "preferences" => %{"lower_limit" => 30, "upper_limit" => 50},
#       "module" => "Elixir.AcqdatCore.Schema.Notification.RangeBased"
#     }
#   }

#   describe "handle_notification/1" do
#     setup do
#       device = insert(:device)
#       sensor = insert(:sensor, device: device, name: "Temperature")

#       [sensor: sensor, device: device]
#     end

#     test "does not send if config not found", context do
#       %{sensor: sensor, device: device} = context
#       insert(:sensor_notification)
#       data = %{"#{sensor.name}" => %{"temp" => 10, "humid" => 30}}
#       params = %{device: device, data: data}

#       result = Notification.handle_notification(params)
#       assert Enum.any?(result, fn x -> x == {:error, "no rules set"} end)
#     end

#     test "does not send if config has alarm set to false", context do
#       %{sensor: sensor, device: device} = context
#       insert(:sensor_notification, sensor: sensor, rule_values: @rule_values, alarm_status: false)
#       data = %{"#{sensor.name}" => %{"temp" => 10, "humid" => 30}}
#       params = %{device: device, data: data}

#       result = Notification.handle_notification(params)
#       assert Enum.any?(result, fn x -> x == {:error, "alarm disabled"} end)
#     end

#     test "does not send if rules are not met", context do
#       %{sensor: sensor, device: device} = context
#       insert(:sensor_notification, sensor: sensor, rule_values: @rule_values, alarm_status: true)
#       data = %{"#{sensor.name}" => %{"temp" => 10, "humid" => 20}}
#       params = %{device: device, data: data}

#       result = Notification.handle_notification(params)
#       assert Enum.any?(result, fn x -> x == {:error, "not eligible"} end)
#     end

#     test "sends if config has alarm set to true", context do
#       %{sensor: sensor, device: device} = context
#       insert(:sensor_notification, sensor: sensor, rule_values: @rule_values, alarm_status: true)
#       data = %{"#{sensor.name}" => %{"temp" => 90, "humid" => 35}}
#       params = %{device: device, data: data}

#       result = Notification.handle_notification(params)
#       assert {:ok, "notification_sent"} == result
#     end
#   end
# end
