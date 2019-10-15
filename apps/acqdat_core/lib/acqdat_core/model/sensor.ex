defmodule AcqdatCore.Model.Sensor do
  alias AcqdatCore.Schema.{Sensor, SensorData}
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = Sensor.changeset(%Sensor{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Sensor, id) do
      nil ->
        {:error, "not found"}

      sensor ->
        {:ok, sensor}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Sensor, query) do
      nil ->
        {:error, "not found"}

      sensor ->
        {:ok, sensor}
    end
  end

  def get_all_by_device(device_id) do
    query =
      from(sensor in Sensor,
        where: sensor.device_id == ^device_id,
        select: sensor
      )

    Repo.all(query)
  end

  def update(sensor, params) do
    changeset = Sensor.update_changeset(sensor, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(Sensor)
  end

  def delete(id) do
    Sensor
    |> Repo.get(id)
    |> Repo.delete()
  end

  def insert_data(sensor, sensor_data) do
    params = %{
      sensor_id: sensor.id,
      datapoint: sensor_data,
      inserted_timestamp: DateTime.utc_now()
    }

    changeset = SensorData.changeset(%SensorData{}, params)

    Repo.insert(changeset)
  end

  def sensor_data(sensor_id, identifier) do
    query =
      from(
        data in SensorData,
        where: data.sensor_id == ^sensor_id,
        order_by: data.inserted_timestamp,
        select: [data.inserted_timestamp, fragment("? ->> ?", data.datapoint, ^identifier)]
      )

    stream = Repo.stream(query)

    {:ok, result} =
      Repo.transaction(fn ->
        Enum.map(stream, fn [date, value] ->
          {value, _} = Float.parse(value)
          [DateTime.to_unix(date, :millisecond), value]
        end)
      end)

    result
  end
end
