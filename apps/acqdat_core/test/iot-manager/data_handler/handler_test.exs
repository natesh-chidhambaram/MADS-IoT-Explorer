defmodule AcqdatCore.IotManager.DataHandlerTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.IotManager.DataHandler
  alias AcqdatCore.Model.IotManager.GatewayDataDump

  describe "dump_test http" do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      gateway = insert(:gateway, org: org, project: project, timestamp_mapping: "timestamp")

      params = %{
        "axis_object" => %{
          "x_axis" => 20,
          "z_axis" => [22, 23],
          "lambda" => %{"alpha" => 24, "beta" => 25}
        },
        "y_axis" => 21,
        "project_id" => 1,
        "xyz" => %{},
        "timestamp" => 1_596_115_581
      }

      dump_params = %{
        org_uuid: org.uuid,
        project_uuid: project.uuid,
        gateway_uuid: gateway.uuid,
        data: params,
        mode: "http"
      }

      [dump_params: dump_params]
    end

    test "logs error if duplicate_timestamp", context do
      %{dump_params: dump_params} = context

      GatewayDataDump.create(dump_params)

      {:error, result} = DataHandler.insert_data(dump_params)

      assert %{
               inserted_timestamp: ["duplicate data with same timestamp inserted"]
             } == result.error
    end

    test "logs error if invalid_timestamp", context do
      %{dump_params: dump_params} = context
      data = dump_params.data
      updated_data = Map.put(data, "timestamp", 1_596_115_581_000)

      ## change timestamp to include invalid unix value
      dump_params = Map.put(dump_params, :data, updated_data)

      {:error, result} = DataHandler.insert_data(dump_params)

      assert %{
               message: "timestamp not supported"
             } == result.error
    end
  end
end
