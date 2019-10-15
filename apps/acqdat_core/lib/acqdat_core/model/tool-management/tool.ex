defmodule AcqdatCore.Model.ToolManagement.Tool do
  @moduledoc """
  Exposes APIs to interact with tool DB table.
  """

  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.{Tool, ToolIssue}

  def create(params) do
    changeset = Tool.create_changeset(%Tool{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Tool, id) do
      nil ->
        {:error, "not found"}

      tool ->
        {:ok, tool}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Tool, query) do
      nil ->
        {:error, "not found"}

      tool ->
        {:ok, tool}
    end
  end

  def update(tool, params) do
    changeset = Tool.update_changeset(tool, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(Tool)
  end

  def delete(id) do
    Tool
    |> Repo.get(id)
    |> Repo.delete()
  end

  @spec get_all_by_uuids_and_status(list, String.t()) :: [non_neg_integer]
  def get_all_by_uuids_and_status(uuids, status) do
    query =
      from(
        tool in Tool,
        where: tool.uuid in ^uuids and tool.status == ^status,
        select: tool.id
      )

    Repo.all(query)
  end

  @doc """
  Updates tool status with supplied status in params.
  Takes as input a list of tool_ids and status.
  """
  def update_tool_status(tool_ids, status) do
    query =
      from(
        tool in Tool,
        where: tool.id in ^tool_ids
      )

    {_, updates} = Repo.update_all(query, set: [status: status])
    updates
  end

  def get_tool_latest_issue_id(tool_id) do
    query =
      from(
        issue in ToolIssue,
        group_by: issue.id,
        having: issue.tool_id == ^tool_id,
        order_by: [desc: issue.issue_time],
        limit: 1,
        select: issue.id
      )

    Repo.one(query)
  end
end
