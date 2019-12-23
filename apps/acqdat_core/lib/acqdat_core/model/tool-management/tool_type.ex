defmodule AcqdatCore.Model.ToolManagement.ToolType do
  @moduledoc """
  Exposes APIs to interact with tool_type DB table.
  """

  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.ToolType

  def create(params) do
    changeset = ToolType.changeset(%ToolType{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(ToolType, id) do
      nil ->
        {:error, "not found"}

      tool_type ->
        {:ok, tool_type}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(ToolType, query) do
      nil ->
        {:error, "not found"}

      tool_type ->
        {:ok, tool_type}
    end
  end

  def update(tool_type, params) do
    changeset = ToolType.changeset(tool_type, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(ToolType)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    ToolType
    |> order_by(:id)
    |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def delete(id) do
    ToolType
    |> Repo.get(id)
    |> Repo.delete()
  end

  @spec formatted_list() :: [{String.t(), non_neg_integer}]
  def formatted_list do
    ToolType
    |> order_by([s], asc: s.identifier)
    |> select([s], {s.identifier, s.id})
    |> Repo.all()
  end
end
