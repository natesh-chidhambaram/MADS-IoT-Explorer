defmodule AcqdatCore.Schema.DeviceTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.Device

  describe "changeset/2" do
    test "adds uuid to changeset and returns valid changeset" do
      params = %{
        name: "Arduino 1",
        description: "handles temp & humid",
        access_token: "$abcd123"
      }

      %{valid?: validity} = Device.changeset(%Device{}, params)
      assert validity
    end

    test "returns invalid changeset if name not unique" do
      device = insert(:device)

      params = %{
        name: device.name,
        uuid: UUID.uuid1(:hex),
        access_token: "abcd1234",
        description: "new device"
      }

      changeset = Device.changeset(%Device{}, params)

      assert {:error, changeset} = Repo.insert(changeset)
      assert %{name: ["has already been taken"]} == errors_on(changeset)
    end

    test "fails if params missing" do
      assert %{valid?: validity} = changeset = Device.changeset(%Device{}, %{})
      refute validity

      assert %{
               access_token: ["can't be blank"],
               name: ["can't be blank"]
             } == errors_on(changeset)
    end
  end
end
