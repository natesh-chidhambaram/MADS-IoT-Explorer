defmodule AcqdatCore.Seed.SensorType do

  alias AcqdatCore.Schema.SensorType
  alias AcqdatCore.Repo

  @type_list [
    %{name: "Temperature", make: "Adafruit", visualizer: "", identifier: "temperature",
      value_keys: ["temp"]},
    %{name: "Humidity", make: "Adafruit", visualizer: "", identifier: "humidity",
      value_keys: ["hum"]},
    %{name: "Accelerometer", make: "Sparkfun", visualizer: "", identifier: "accelerometer",
      value_keys: ["ax", "ay", "az"]},
    %{name: "Gyro", make: "Adafruit", visualizer: "", identifier: "gyroscope",
      value_keys: ["gx", "gy", "gz"]},
    %{name: "Light", make: "Adafruit", visualizer: "", identifier: "light",
      value_keys: ["lum"]},
  ]

  def seed_sensor_types() do
    entries = @type_list
    |> Enum.map(fn sensor_type ->
      sensor_type
      |> Map.put(:inserted_at, DateTime.truncate(DateTime.utc_now(), :second))
      |> Map.put(:updated_at, DateTime.truncate(DateTime.utc_now(), :second))
    end)

    Repo.insert_all(SensorType, entries)

  end

end
