# defmodule AcqdatCore.Schema.SensorTest do
#   use ExUnit.Case, async: true
#   use AcqdatCore.DataCase

#   import AcqdatCore.Support.Factory

#   alias AcqdatCore.Schema.Sensor

#   describe "changeset/2" do
#     setup do
#       device = insert(:device)
#       sensor_type = insert(:sensor_type)

#       [device: device, sensor_type: sensor_type]
#     end

#     test "returns a valid changeset", context do
#       %{device: device, sensor_type: sensor_type} = context

#       params = %{
#         uuid: UUID.uuid1(:hex),
#         name: "Temperature",
#         device_id: device.id,
#         sensor_type_id: sensor_type.id
#       }

#       %{valid?: validity} = Sensor.changeset(%Sensor{}, params)
#       assert validity
#     end

#     test "returns invalid if params empty" do
#       %{valid?: validity} = changeset = Sensor.changeset(%Sensor{}, %{})
#       refute validity

#       assert %{
#                device_id: ["can't be blank"],
#                name: ["can't be blank"],
#                sensor_type_id: ["can't be blank"]
#              } = errors_on(changeset)
#     end

#     test "returns error if assoc constraint not satisfied", context do
#       %{sensor_type: sensor_type} = context

#       params = %{
#         uuid: UUID.uuid1(:hex),
#         name: "Temperature",
#         device_id: -1,
#         sensor_type_id: sensor_type.id
#       }

#       changeset = Sensor.changeset(%Sensor{}, params)

#       {:error, result_changeset} = Repo.insert(changeset)
#       assert %{device: ["does not exist"]} == errors_on(result_changeset)
#     end

#     test "returns error if unique constraint not satisified", context do
#       %{device: device} = context

#       params = %{
#         uuid: UUID.uuid1(:hex),
#         name: "Temperature",
#         device_id: device.id,
#         sensor_type_id: -1
#       }

#       changeset = Sensor.changeset(%Sensor{}, params)

#       {:error, result_changeset} = Repo.insert(changeset)
#       assert %{sensor_type: ["does not exist"]} == errors_on(result_changeset)
#     end
#   end
# end
