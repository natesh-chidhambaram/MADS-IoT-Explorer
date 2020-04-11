defmodule AcqdatCore.Seed.Sensor do
  #TODO
  # alias AcqdatCore.Schema.{Sensor}
  # alias AcqdatCore.Repo

  # def seed_sensors() do
  #   [device_1, device_2, device_3] = Repo.all(Device)

  #   sensor_types = Repo.all(SensorType)

  #   sensors = sensor_types
  #   |> Enum.map(fn
  #     %SensorType{identifier: "temperature"} = sensor_type ->
  #         %{sensor_type_id: sensor_type.id, device_id: device_1.id, uuid: UUID.uuid1(:hex), name: "Temperature"}
  #     %SensorType{identifier: "humidity"} = sensor_type ->
  #       %{sensor_type_id: sensor_type.id, device_id: device_1.id, uuid: UUID.uuid1(:hex), name: "Humidity"}
  #     %SensorType{identifier: "accelerometer"} = sensor_type ->
  #       %{sensor_type_id: sensor_type.id, device_id: device_2.id, uuid: UUID.uuid1(:hex), name: "Accelerometer"}
  #     %SensorType{identifier: "gyroscope"} = sensor_type ->
  #       %{sensor_type_id: sensor_type.id, device_id: device_2.id, uuid: UUID.uuid1(:hex), name: "Gyroscope"}
  #     %SensorType{identifier: "light"} = sensor_type ->
  #       %{sensor_type_id: sensor_type.id, device_id: device_3.id, uuid: UUID.uuid1(:hex), name: "Light"}
  #     end)
  #   |> Enum.map(fn sensor ->
  #     sensor
  #     |> Map.put(:inserted_at, DateTime.truncate(DateTime.utc_now(), :second))
  #     |> Map.put(:updated_at, DateTime.truncate(DateTime.utc_now(), :second))
  #   end)

  #   Repo.insert_all(Sensor, sensors)
  # end
end
