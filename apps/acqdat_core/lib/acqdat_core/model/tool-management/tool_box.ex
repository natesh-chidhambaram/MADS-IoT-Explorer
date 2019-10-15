defmodule AcqdatCore.Model.ToolManagement.ToolBox do
  @moduledoc """
  Exposes APIs to interact with tool_box DB table.
  """

  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.ToolBox

  def create(params) do
    changeset = ToolBox.create_changeset(%ToolBox{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(ToolBox, id) do
      nil ->
        {:error, "not found"}

      tool_box ->
        {:ok, tool_box}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(ToolBox, query) do
      nil ->
        {:error, "not found"}

      tool_box ->
        {:ok, tool_box}
    end
  end

  def update(tool_box, params) do
    changeset = ToolBox.update_changeset(tool_box, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(ToolBox)
  end

  def delete(id) do
    ToolBox
    |> Repo.get(id)
    |> Repo.delete()
  end
end
