defmodule AcqdatCore.Schema.EntityManagement.SensorType do
  @moduledoc """
  Models a sensor-type in the system.

  A sensor-type is responsible for deciding the parameters of a IoT data sensor. Sensor will have the ID
  sensor-type deciding the parameters of that sensor
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
  alias alias AcqdatCore.Schema.EntityManagement.Sensor
  alias AcqdatCore.Repo
  import Ecto.Query

  @generated_by ~w(user asset)a

  @typedoc """
  `name`: A unique name for sensor per device. Note the same
          name can be used for sensor associated with another
          device.
   `description`: A description of the sensor-type
   `metadata`: A metadata field which will store all the data related to sensor-type
   `org_id`: A organisation to which the sensor and corresponding sensor-type is belonged to.
  `parameters`: The different parameters of the sensor.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_sensor_types") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string, null: false)
    field(:description, :string)
    field(:generated_by, GeneratedBy, default: "user")

    embeds_many :metadata, Metadata, on_replace: :delete do
      field(:name, :string, null: false)
      field(:data_type, :string, null: false)
      field(:uuid, :string, null: false)
      field(:unit, :string)
    end

    embeds_many :parameters, Parameters, on_replace: :delete do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
      field(:unit, :string)
    end

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:project, Project, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid slug project_id org_id name)a
  @optional_params ~w(description generated_by)a
  @embedded_metadata_required ~w(name uuid data_type)a
  @embedded_metadata_optional ~w(unit)a
  @permitted_metadata @embedded_metadata_optional ++ @embedded_metadata_required
  @embedded_required_params ~w(name uuid data_type)a
  @embedded_optional_params ~w(unit)a
  @permitted_embedded @embedded_optional_params ++ @embedded_required_params

  @permitted @required_params ++ @optional_params

  def changeset(%__MODULE__{} = sensor_type, params) do
    sensor_type
    |> cast(params, @permitted)
    |> cast_embed(:parameters, with: &parameters_changeset/2)
    |> cast_embed(:metadata, with: &metadata_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = sensor_type, params) do
    sensor_type
    |> cast(params, @permitted)
    |> prepare_st_parameters(sensor_type, params)
    |> cast_embed(:parameters, with: &update_parameters_changeset/2)
    |> check_for_parameter_name_uniqueness(sensor_type)
    |> prepare_st_metadata(sensor_type, params)
    |> cast_embed(:metadata, with: &update_metadata_changeset/2)
    |> check_for_metadata_name_uniqueness(sensor_type)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  defp prepare_st_parameters(changeset, sensor_type, %{"parameters" => parameters} = params) do
    case create_params(params, sensor_type, parameters) do
      {:ok, parameters} ->
        Map.replace!(changeset, :params, parameters)

      {:error, message} ->
        case List.first(changeset.errors) do
          nil ->
            Ecto.Changeset.add_error(changeset, :parameters, message)
            |> Map.replace!(:valid?, false)

          _value ->
            changeset
        end
    end
  end

  defp prepare_st_parameters(changeset, _sensor_type, _params) do
    changeset
  end

  defp prepare_st_metadata(changeset, sensor_type, %{"metadata" => metadata} = params) do
    case create_metadata(params, sensor_type, metadata) do
      {:ok, parameters} ->
        Map.replace!(changeset, :params, parameters)

      {:error, message} ->
        case List.first(changeset.errors) do
          nil ->
            Ecto.Changeset.add_error(changeset, :metadata, message)
            |> Map.replace!(:valid?, false)

          _value ->
            changeset
        end
    end
  end

  defp prepare_st_metadata(changeset, _sensor_type, _params) do
    changeset
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:project)
    |> unique_constraint(:slug, name: :acqdat_sensor_types_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_sensor_types_uuid_index)
    |> unique_constraint(:name,
      name: :acqdat_sensor_types_name_org_id_project_id_index,
      message: "sensor type already exists"
    )
  end

  def generated_by() do
    @generated_by
  end

  defp parameters_changeset(schema, params) do
    schema
    |> cast(params, @permitted_embedded)
    |> add_uuid()
    |> validate_required(@embedded_required_params)
  end

  defp metadata_changeset(schema, params) do
    schema
    |> cast(params, @permitted_metadata)
    |> add_uuid()
    |> validate_required(@embedded_metadata_required)
  end

  defp check_for_parameter_name_uniqueness(changeset, sensor_type) do
    case Map.has_key?(changeset.changes, :parameters) do
      true -> find_uniqueness(changeset, sensor_type, :parameters)
      false -> changeset
    end
  end

  defp check_for_metadata_name_uniqueness(changeset, sensor_type) do
    case Map.has_key?(changeset.changes, :metadata) do
      true -> find_uniqueness(changeset, sensor_type, :metadata)
      false -> changeset
    end
  end

  defp find_uniqueness(changeset, sensor_type, :parameters) do
    current_mapped_parameters_name =
      Enum.reduce(sensor_type.parameters, [], fn params, acc ->
        acc ++ [params.name]
      end)

    parameters =
      Enum.reduce(changeset.changes.parameters, [], fn params, acc ->
        case Map.has_key?(params.changes, :name) do
          true ->
            case Enum.member?(current_mapped_parameters_name, params.changes.name) do
              true ->
                params =
                  Ecto.Changeset.add_error(params, :name, "Parameter name already taken")
                  |> Map.replace!(:valid?, false)

                acc ++ [params]

              false ->
                acc ++ [params]
            end

          false ->
            acc ++ [params]
        end
      end)

    valid_flags =
      Enum.reduce(parameters, [], fn params, acc ->
        acc ++ [params.valid?]
      end)

    changes = Map.replace(changeset.changes, :parameters, parameters)

    case Enum.member?(valid_flags, false) do
      true ->
        Map.replace!(changeset, :changes, changes) |> Map.replace!(:valid?, false)

      false ->
        Map.replace!(changeset, :changes, changes)
    end
  end

  defp find_uniqueness(changeset, sensor_type, :metadata) do
    current_mapped_metadata_name =
      Enum.reduce(sensor_type.metadata, [], fn params, acc ->
        acc ++ [params.name]
      end)

    metadata =
      Enum.reduce(changeset.changes.metadata, [], fn params, acc ->
        case Map.has_key?(params.changes, :name) do
          true ->
            case Enum.member?(current_mapped_metadata_name, params.changes.name) do
              true ->
                params =
                  Ecto.Changeset.add_error(params, :name, "Metadata name already taken")
                  |> Map.replace!(:valid?, false)

                acc ++ [params]

              false ->
                acc ++ [params]
            end

          false ->
            acc ++ [params]
        end
      end)

    valid_flags =
      Enum.reduce(metadata, [], fn params, acc ->
        acc ++ [params.valid?]
      end)

    changes = Map.replace(changeset.changes, :metadata, metadata)

    case Enum.member?(valid_flags, false) do
      true ->
        Map.replace!(changeset, :changes, changes) |> Map.replace!(:valid?, false)

      false ->
        Map.replace!(changeset, :changes, changes)
    end
  end

  defp create_params(params, sensor_type, parameters) do
    # previous already mapped parameters to the sensor
    previous_parameters =
      Enum.reduce(sensor_type.parameters, [], fn params, acc ->
        acc ++ [params.uuid]
      end)
      |> MapSet.new()

    # new upcoming parameters which can contain existing already mapped parameters or request to map new parameter
    current_parameters =
      Enum.reduce(parameters, [], fn params, acc ->
        case Map.has_key?(params, "uuid") do
          true -> acc ++ [params["uuid"]]
          false -> acc
        end
      end)
      |> MapSet.new()

    deleted_parameters =
      MapSet.to_list(MapSet.difference(previous_parameters, current_parameters))

    case is_nil(List.first(deleted_parameters)) do
      false ->
        case check_dependency(sensor_type) do
          {:ok, _sensor_type} -> {:ok, Map.replace!(params, "parameters", parameters)}
          {:error, message} -> {:error, message}
        end

      true ->
        {:ok, Map.replace!(params, "parameters", parameters)}
    end
  end

  defp create_metadata(params, sensor_type, metadata) do
    # previous already mapped parameters to the sensor
    previous_metadata =
      Enum.reduce(sensor_type.metadata, [], fn params, acc ->
        acc ++ [params.uuid]
      end)
      |> MapSet.new()

    # new upcoming parameters which can contain existing already mapped parameters or request to map new parameter
    current_metadata =
      Enum.reduce(metadata, [], fn params, acc ->
        case Map.has_key?(params, "uuid") do
          true -> acc ++ [params["uuid"]]
          false -> acc
        end
      end)
      |> MapSet.new()

    deleted_metadata = MapSet.to_list(MapSet.difference(previous_metadata, current_metadata))

    case is_nil(List.first(deleted_metadata)) do
      false ->
        case check_dependency(sensor_type) do
          {:ok, _sensor_type} -> {:ok, Map.replace!(params, "metadata", metadata)}
          {:error, message} -> {:error, message}
        end

      true ->
        {:ok, Map.replace!(params, "metadata", metadata)}
    end
  end

  defp update_parameters_changeset(schema, params) do
    schema =
      schema
      |> cast(params, @permitted_embedded)

    schema = if params["uuid"] == nil, do: add_uuid(schema), else: schema

    validate_required(schema, @embedded_required_params)
  end

  defp update_metadata_changeset(schema, params) do
    schema =
      schema
      |> cast(params, @permitted_metadata)

    schema = if params["uuid"] == nil, do: add_uuid(schema), else: schema

    validate_required(schema, @embedded_metadata_required)
  end

  defp check_sensor_relation(sensor_type) do
    query =
      from(sensor in Sensor,
        where: sensor.sensor_type_id == ^sensor_type.id
      )

    List.first(Repo.all(query))
  end

  defp check_dependency(sensor_type) do
    case is_nil(check_sensor_relation(sensor_type)) do
      true ->
        {:ok, sensor_type}

      false ->
        {:error, "Sensor is Associated to this Sensor Type"}
    end
  end
end
