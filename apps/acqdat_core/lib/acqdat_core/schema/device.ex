defmodule AcqdatCore.Schema.Device do
  @moduledoc """
  Models a device in the system.

  A device can be any entity directly sending data to the acqdat
  platform.
  """
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.Sensor
  alias AcqdatCore.Schema.Site

  @typedoc """
  `uuid`: A universally unique id to identify the device.
  `name`: Name for easy identification of the device.
  `access_token`: Access token to be used while sending data
              to server from the device.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_devices") do
    field(:uuid, :string)
    field(:name, :string)
    field(:image_url, :string)
    field(:image, :any, virtual: true)
    field(:access_token, :string)
    field(:description, :string)

    has_many(:sensors, Sensor)
    belongs_to(:site, Site)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name access_token uuid)a
  @optional_params ~w(description site_id image_url)a

  @permitted @required_params ++ @optional_params
  @update_required_params ~w(name access_token)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = device, params) do
    device
    |> cast(params, @permitted)
    |> add_uuid()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = device, params) do
    device
    |> cast(params, @permitted)
    |> validate_required(@update_required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> unique_constraint(:name, name: :acqdat_devices_name_index)
    |> unique_constraint(:uuid, name: :acqdat_devices_uuid_index)
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end
end
