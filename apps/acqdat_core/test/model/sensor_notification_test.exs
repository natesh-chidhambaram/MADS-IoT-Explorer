defmodule AcqdatCore.Model.SensorNotificationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.SensorNotification, as: SNotify

  describe "get_by_sensor/1" do
    test "returns config when it exists for sensor" do
      sensor = insert(:sensor)
      insert(:sensor_notification, sensor: sensor)

      result = SNotify.get_by_sensor(sensor.id)
      assert not is_nil(result)
      assert result.sensor_id == sensor.id
    end

    test "returns nil if config not set" do
      sensor = insert(:sensor)
      insert(:sensor_notification)

      result = SNotify.get_by_sensor(sensor.id)
      assert result == nil
    end
  end
end
