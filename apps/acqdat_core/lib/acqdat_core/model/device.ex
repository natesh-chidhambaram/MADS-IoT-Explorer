defmodule AcqdatCore.Model.Device do
  import Ecto.Query
  alias AcqdatCore.Schema.Device
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Sensor
  alias AcqdatCore.Domain.Notification.Server, as: NotificationServer
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = Device.changeset(%Device{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Device, id) do
      nil ->
        {:error, "not found"}

      device ->
        {:ok, device}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Device, query) do
      nil ->
        {:error, "not found"}

      device ->
        {:ok, device}
    end
  end

  def update(device, params) do
    changeset = Device.update_changeset(device, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(Device)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Device |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def delete(id) do
    Device
    |> Repo.get(id)
    |> Repo.delete()
  end

  @doc """
  Adds data for the device provided in the params.

  Expects following keys:
  `device_id` => expect device uuid field to be sent under the key.
  `sensor_data` => expects a map which contains data for all the sensors
                   configured for the device.
  `timestamp` => utc timestamp from the device when data was collected.
  """
  @spec add_data(map) ::
          {:ok, AcqdatCore.Schema.SensorData.t()}
          | {:error, String.t()}
          | {:error, Ecto.Changeset.t()}
  def add_data(params) do
    %{"device_id" => uuid, "sensor_data" => data, "timestamp" => _timestamp} = params

    case get(%{uuid: uuid}) do
      {:ok, device} ->
        insert_data(device, data)

      {:error, message} ->
        {:error, message}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_device_data =
      Device |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    device_data_with_preloads = paginated_device_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(device_data_with_preloads, paginated_device_data)
  end

  def get_all_by_criteria(id, preloads) when is_integer(id) do
    query =
      from(device in Device,
        where: device.site_id == ^id,
        select: device
      )

    Repo.all(query) |> Repo.preload(preloads)
  end

  defp insert_data(device, data) do
    # handle notification, move or modify the location of this call.
    params = %{device: device, data: data}
    NotificationServer.handle_notification(params)

    result_array =
      Enum.map(data, fn {sensor, sensor_data} ->
        result = Sensor.get(%{device_id: device.id, name: sensor})
        insert_sensor_data(result, sensor_data)
      end)

    if Enum.any?(result_array, fn {status, _data} -> status == :error end) do
      {:error, "insert error"}
    else
      {:ok, "data inserted successfully"}
    end
  end

  defp insert_sensor_data({:error, _data}, _), do: {:error, "sensor not found"}

  defp insert_sensor_data({:ok, sensor}, sensor_data) do
    Sensor.insert_data(sensor, sensor_data)
  end
end
