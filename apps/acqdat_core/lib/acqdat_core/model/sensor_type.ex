defmodule AcqdatCore.Model.SensorType do
  @moduledoc """
  Exposes APIs for handling sensor type entity.
  """

  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.SensorType

  @doc """
  Creates a new sensor type.
  """
  @spec create(map) :: {:ok, SensorType.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    changeset = SensorType.changeset(%SensorType{}, params)
    Repo.insert(changeset)
  end

  def get_all() do
    Repo.all(SensorType)
  end

  def get(id) when is_integer(id) do
    case Repo.get(SensorType, id) do
      nil ->
        {:error, "not found"}

      sensor_type ->
        {:ok, sensor_type}
    end
  end

  def get(query) when is_map(query) do
    Repo.get_by(SensorType, query)
  end

  @spec update(SensorType.t(), map) :: {:ok, SensorType.t()} | {:error, Ecto.Changeset.t()}
  def update(sensor_type, params) do
    changeset = SensorType.changeset(sensor_type, params)
    Repo.update(changeset)
  end

  def delete(id) do
    SensorType
    |> Repo.get(id)
    |> Repo.delete()
  end

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    SensorType
    |> order_by([s], asc: s.name)
    |> select([s], {s.name, s.id})
    |> Repo.all()
  end
end
