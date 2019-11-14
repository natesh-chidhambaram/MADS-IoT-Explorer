defmodule AcqdatApi.SensorType do
  alias AcqdatCore.Schema.SensorType
  alias AcqdatCore.Model.SensorType, as: SensorTypeModel

  def create(params) do
    %{
      name: name,
      make: make,
      value_keys: value_keys,
      visualizer: visualizer,
      identifier: identifier
    } = params

    verify_sensor_type(
      SensorTypeModel.create(%{
        name: name,
        make: make,
        value_keys: value_keys,
        visualizer: visualizer,
        identifier: identifier
      })
    )
  end

  defp verify_sensor_type({:ok, sensor_type}) do
    {:ok,
     %{
       sensor_id: sensor_type.id,
       name: sensor_type.name,
       make: sensor_type.make,
       identifier: sensor_type.identifier
     }}
  end

  defp verify_sensor_type({:error, sensor_type}) do
    {:error, %{error: convert_changeset_errors(sensor_type)}}
  end

  defp convert_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
