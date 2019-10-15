defmodule AcqdatCore.Seed.Device do

  alias AcqdatCore.Schema.Device
  alias AcqdatCore.Repo

  @device_manifest [
    %{uuid: "3108061e733a11e9a42fe86a64b144a9", name: "Device1", access_token: "abcd1234"},
    %{uuid: "3ba2997c733a11e98af6e86a64b144a9", name: "Device2", access_token: "abcd4567"},
    %{uuid: "473046ae733a11e9add8e86a64b144a9", name: "Device3", access_token: "abcd7654"}
  ]

  def see_device!() do
    entries = @device_manifest
    |> Enum.map(fn sensor_type ->
      sensor_type
      |> Map.put(:inserted_at, DateTime.truncate(DateTime.utc_now(), :second))
      |> Map.put(:updated_at, DateTime.truncate(DateTime.utc_now(), :second))
    end)

    Repo.insert_all(Device, entries)
  end
end
