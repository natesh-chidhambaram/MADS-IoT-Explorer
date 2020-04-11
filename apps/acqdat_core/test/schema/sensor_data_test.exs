# defmodule AcqdatCore.Schema.SensorDataTest do
#   use ExUnit.Case, async: true
#   use AcqdatCore.DataCase
#   import AcqdatCore.Support.Factory

#   alias AcqdatCore.Schema.SensorData

#   describe "changeset/2" do
#     setup do
#       device = insert(:device)

#       sensor_type =
#         insert(:sensor_type,
#           name: "Temperature",
#           make: "From Adafruit",
#           identifier: "temperature",
#           visualizer: "pie-chart",
#           value_keys: ["temp"]
#         )

#       sensor =
#         insert(:sensor,
#           device: device,
#           sensor_type: sensor_type,
#           name: "Temperature",
#           uuid: UUID.uuid1(:hex)
#         )

#       [sensor: sensor]
#     end

#     test "returns a valid changeset and makes insert", context do
#       %{sensor: sensor} = context

#       params = %{
#         datapoint: %{"temp" => 23, "humid" => 10},
#         inserted_timestamp: DateTime.utc_now(),
#         sensor_id: sensor.id
#       }

#       %{valid?: validity} = changeset = SensorData.changeset(%SensorData{}, params)
#       assert validity

#       assert {:ok, data} = Repo.insert(changeset)
#     end

#     test "fails if sensor not found" do
#       params = %{
#         datapoint: %{"temp" => 23, "humid" => 10},
#         inserted_timestamp: DateTime.utc_now(),
#         sensor_id: -1
#       }

#       %{valid?: validity} = changeset = SensorData.changeset(%SensorData{}, params)
#       assert validity

#       assert {:error, result_changeset} = Repo.insert(changeset)

#       assert %{sensor: ["does not exist"]} == errors_on(result_changeset)
#     end
#   end
# end
