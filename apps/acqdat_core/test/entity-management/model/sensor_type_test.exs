defmodule AcqdatCore.Model.EntityManagement.SensorTypeTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.EntityManagement.SensorType

  describe "update/2 " do
    setup do
      [sensor_type: insert(:sensor_type)]
    end

    test "update sensor type new parameters", context do
      %{sensor_type: sensor_type} = context
      params = %{"parameters" => [%{"name" => "voltage", "data_type" => "float", "unit" => "V"}]}
      {:ok, updated_sensor_type} = SensorType.update(sensor_type, params)
      [param5] = flat_parameters(updated_sensor_type.parameters)

      assert param5.name == "voltage"
      assert param5.data_type == "float"
      assert param5.unit == "V"
    end

    test "try deleting sensor type parameters which has sensor attached", context do
      %{sensor_type: sensor_type} = context
      sensor = insert(:sensor, sensor_type: sensor_type)

      params = %{"parameters" => [%{"name" => "voltage", "data_type" => "float", "unit" => "V"}]}
      {:error, error} = SensorType.update(sensor_type, params)

      error =
        traverse_errors(error, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

      assert error == %{parameters: ["Sensor is Associated to this Sensor Type"]}
    end

    test "update sensor type new metadata", context do
      %{sensor_type: sensor_type} = context
      params = %{"metadata" => [%{"name" => "voltage", "data_type" => "float", "unit" => "V"}]}

      {:ok, updated_sensor_type} = SensorType.update(sensor_type, params)
      [param7] = flat_parameters(updated_sensor_type.metadata)
      assert param7.name == "voltage"
      assert param7.data_type == "float"
      assert param7.unit == "V"
    end

    test "update sensor type new metadata and parameter", context do
      %{sensor_type: sensor_type} = context
      [param1, param2] = flat_parameters(sensor_type.metadata)

      params = %{
        "metadata" => [
          %{"name" => "voltage", "data_type" => "float", "unit" => "V"}
        ],
        "parameters" => [
          %{"name" => "voltage", "data_type" => "float", "unit" => "V"}
        ]
      }

      {:ok, updated_sensor_type} = SensorType.update(sensor_type, params)
      [param7] = flat_parameters(updated_sensor_type.metadata)
      [param10] = flat_parameters(updated_sensor_type.parameters)
      assert param7.name == "voltage"
      assert param7.data_type == "float"
      assert param7.unit == "V"
      assert param10.name == "voltage"
      assert param10.data_type == "float"
      assert param10.unit == "V"
    end

    test "update sensor type without metadata and parameter", context do
      %{sensor_type: sensor_type} = context
      [param1, param2] = flat_parameters(sensor_type.metadata)
      [param3, param4] = flat_parameters(sensor_type.parameters)

      params = %{
        "name" => "Sensor Type testing without metadata"
      }

      {:ok, updated_sensor_type} = SensorType.update(sensor_type, params)
      [param8, param9] = flat_parameters(updated_sensor_type.parameters)
      assert param3.uuid == param8.uuid
      assert param3.name == param8.name
      assert param3.data_type == param8.data_type
      assert param3.unit == param8.unit
      assert param4.uuid == param9.uuid
      assert param4.name == param9.name
      assert param4.data_type == param9.data_type
      assert param4.unit == param9.unit
      assert updated_sensor_type.name == "Sensor Type testing without metadata"
    end

    test "update sensor type with previous parameter and new parameter", context do
      %{sensor_type: sensor_type} = context
      [param1, param2] = flat_parameters(sensor_type.parameters)

      params = %{
        "parameters" => [
          %{"name" => "voltage", "data_type" => "float", "unit" => "V"},
          %{
            "name" => param1.name,
            "data_type" => "random data type",
            "unit" => param1.unit,
            "id" => param1.id,
            "uuid" => param1.uuid
          }
        ]
      }

      {:ok, updated_sensor_type} = SensorType.update(sensor_type, params)
      [param5, param3] = flat_parameters(updated_sensor_type.parameters)
      assert param1.uuid == param3.uuid
      assert param1.name == param3.name
      assert param3.data_type == "random data type"
      assert param1.unit == param3.unit
      assert param5.name == "voltage"
      assert param5.data_type == "float"
      assert param5.unit == "V"
    end

    test "update sensor type with previous metadata and new metadata", context do
      %{sensor_type: sensor_type} = context
      [param1, param2] = flat_parameters(sensor_type.metadata)

      params = %{
        "metadata" => [
          %{"name" => "voltage", "data_type" => "float", "unit" => "V"},
          %{
            "name" => param1.name,
            "data_type" => "random data type",
            "unit" => param1.unit,
            "id" => param1.id,
            "uuid" => param1.uuid
          }
        ]
      }

      {:ok, updated_sensor_type} = SensorType.update(sensor_type, params)
      [param3, param5] = flat_parameters(updated_sensor_type.metadata)

      assert param1.name == param5.name
      assert param5.data_type == "random data type"
      assert param1.unit == param5.unit
      assert param3.name == "voltage"
      assert param3.data_type == "float"
      assert param3.unit == "V"
    end

    test "update sensor type with same parameter name", context do
      %{sensor_type: sensor_type} = context
      [param1, param2] = flat_parameters(sensor_type.parameters)

      params = %{
        "parameters" => [
          %{"name" => param1.name, "data_type" => "float", "unit" => "V"}
        ]
      }

      {:error, error} = SensorType.update(sensor_type, params)

      error =
        traverse_errors(error, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

      assert error == %{parameters: [%{}, %{}, %{name: ["Parameter name already taken"]}]}
    end

    test "update sensor type with same metadata name", context do
      %{sensor_type: sensor_type} = context
      [param1, param2] = flat_parameters(sensor_type.metadata)

      params = %{
        "metadata" => [
          %{"name" => "voltage", "data_type" => "float", "unit" => "V"},
          %{
            "name" => param2.name,
            "data_type" => "random data type",
            "unit" => param1.unit,
            "id" => param1.id,
            "uuid" => param1.uuid
          }
        ]
      }

      {:error, error} = SensorType.update(sensor_type, params)

      error =
        traverse_errors(error, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

      assert error == %{metadata: [%{}, %{}, %{name: ["Metadata name already taken"]}]}
    end
  end

  defp flat_parameters(params) do
    Enum.reduce(params, [], fn params, acc ->
      acc ++ [Map.from_struct(params)]
    end)
  end
end
