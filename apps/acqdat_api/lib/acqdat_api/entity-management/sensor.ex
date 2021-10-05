defmodule AcqdatApi.EntityManagement.Sensor do
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.ElasticSearch
  import AcqdatApiWeb.Helpers

  defdelegate delete_data(atom, params), to: SensorModel
  defdelegate get_all_sensors_data(params), to: SensorModel

  def create(attrs) do
    verify_sensor(SensorModel.create(sensor_create_attrs(attrs)))
  end

  defp sensor_create_attrs(%{
         sensor_type_id: sensor_type_id,
         metadata: metadata,
         name: name,
         org_id: org_id,
         parent_id: parent_id,
         parent_type: parent_type,
         project_id: project_id,
         description: description
       }) do
    %{
      sensor_type_id: sensor_type_id,
      metadata: metadata,
      name: name,
      org_id: org_id,
      parent_id: parent_id,
      parent_type: parent_type,
      project_id: project_id,
      description: description
    }
  end

  defp verify_sensor({:ok, sensor}) do
    Task.start_link(fn ->
      ElasticSearch.insert_sensor("sensors", sensor)
    end)

    {:ok, sensor}
  end

  defp verify_sensor({:error, sensor}) do
    {:error, extract_changeset_error(sensor)}
  end
end
