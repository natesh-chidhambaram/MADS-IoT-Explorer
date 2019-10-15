defmodule AcqdatCore.Schema.Sensor do
  @moduledoc """
  Models a sensor in the system.

  To handle a sensor entity it is being assumed that a sensor
  can exist only with a device.
  A sensor could have been identified by combination of sensor type
  and device however, a device can have more than one sensor of the
  same type.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.{Device, SensorType, SensorData}

  @typedoc """
  `uuid`: A universallly unique id for the sensor.
  `name`: A unique name for sensor per device. Note the same
          name can be used for sensor associated with another
          device.
  `device_id`: id of the device to which the sensor belongs.
               See `AcqdatCore.Schema.Device`
  `sensor_type_id`: id of the sensor type to which the sensor belongs.
                    See `AcqdatCore.Schema.SensorType`
  """
  @type t :: %__MODULE__{}

  schema("acqdat_sensors") do
    field(:uuid, :string)
    field(:name, :string)

    # associations
    belongs_to(:device, Device, on_replace: :delete)
    belongs_to(:sensor_type, SensorType)

    has_many(:sensor_data, SensorData)
    timestamps(type: :utc_datetime)
  end

  @permitted ~w(device_id sensor_type_id uuid name)a
  @update_params ~w(device_id sensor_type_id name)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = sensor, params) do
    sensor
    |> cast(params, @permitted)
    |> add_uuid()
    |> validate_required(@permitted)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = sensor, params) do
    sensor
    |> cast(params, @update_params)
    |> validate_required(@permitted)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:device)
    |> assoc_constraint(:sensor_type)
    |> unique_constraint(:name, name: :unique_sensor_per_device)
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end
end
