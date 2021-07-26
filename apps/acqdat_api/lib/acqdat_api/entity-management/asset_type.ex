defmodule AcqdatApi.EntityManagement.AssetType do
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: STModel
  alias AcqdatCore.ElasticSearch
  import AcqdatApiWeb.Helpers
  alias Ecto.Multi
  alias AcqdatCore.Repo

  defdelegate get(id), to: AssetTypeModel
  defdelegate update(asset_type, data), to: AssetTypeModel
  defdelegate delete(asset_type), to: AssetTypeModel
  defdelegate get_all(data, preloads), to: AssetTypeModel
  defdelegate get_all(data), to: AssetTypeModel

  def create(params) do
    %{
      sensor_type_present: sensor_type_present
    } = params

    case sensor_type_present do
      true ->
        Multi.new()
        |> Multi.run(:create_sensor_type, fn _, _ ->
          add_sensor_type(params)
        end)
        |> Multi.run(:create_asset_type, fn _, %{create_sensor_type: sensor_type} ->
          add_asset_type(sensor_type, params)
        end)
        |> run_transaction()

      false ->
        verify_asset_type(create_asset(params))
    end
  end

  defp add_asset_type(sensor_type, params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      project_id: project_id
    } = params

    create_asset(%{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      sensor_type_present: true,
      sensor_type_uuid: sensor_type.uuid,
      org_id: org_id,
      project_id: project_id
    })
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end

  def create_asset(params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      sensor_type_present: sensor_type_present,
      sensor_type_uuid: sensor_type_uuid,
      org_id: org_id,
      project_id: project_id
    } = params

    # verify_asset_type(
    AssetTypeModel.create(%{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      sensor_type_present: sensor_type_present,
      sensor_type_uuid: sensor_type_uuid,
      org_id: org_id,
      project_id: project_id
    })

    # )
  end

  defp verify_asset_type({:ok, asset_type}) do
    asset_type = Repo.preload(asset_type, [:project])

    {:ok,
     %{
       id: asset_type.id,
       name: asset_type.name,
       description: asset_type.description,
       metadata: asset_type.metadata,
       parameters: asset_type.parameters,
       org_id: asset_type.org_id,
       slug: asset_type.slug,
       uuid: asset_type.uuid,
       sensor_type_present: asset_type.sensor_type_present,
       sensor_type_uuid: asset_type.sensor_type_uuid,
       project_id: asset_type.project_id,
       project: asset_type.project,
       inserted_at: asset_type.inserted_at
     }}
  end

  defp verify_asset_type({:error, changeset}) do
    {:error, extract_changeset_error(changeset)}
  end

  defp add_sensor_type(params) do
    %{
      name: name,
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      project_id: project_id
    } = params

    params = %{
      name: name <> "-sensor-type",
      description: description,
      metadata: metadata,
      parameters: parameters,
      org_id: org_id,
      generated_by: "asset",
      project_id: project_id
    }

    case STModel.create(params) do
      {:ok, sensor_type} ->
        Task.start_link(fn ->
          ElasticSearch.insert_sensor_type("sensor_types", sensor_type)
        end)

        {:ok, sensor_type}

      {:error, message} ->
        {:error, message}
    end
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{create_sensor_type: _, create_asset_type: create_asset_type}} ->
        verify_asset_type({:ok, create_asset_type})

      {:error, failed_operation, failed_value, _} ->
        case failed_operation do
          :create_sensor_type -> verify_error_changeset({:error, failed_value})
          :create_asset_type -> verify_error_changeset({:error, failed_value})
        end
    end
  end
end
