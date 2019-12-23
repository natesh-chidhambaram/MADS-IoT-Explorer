defmodule AcqdatCore.Model.ToolManagement.Tool do
  @moduledoc """
  Exposes APIs to interact with tool DB table.
  """

  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.{Tool, ToolIssue}

  def create(params) do
    changeset = Tool.create_changeset(%Tool{}, params)

    with {:ok, changeset} <- Repo.insert(changeset) do
      {:ok, changeset |> Repo.preload([:tool_box, :tool_type])}
    else
      {:error, error} -> {:error, error}
    end
  end

  def get(id) when is_integer(id) do
    case Repo.get(Tool, id) do
      nil ->
        {:error, "not found"}

      tool ->
        {:ok, tool |> Repo.preload([:tool_box, :tool_type])}
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

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_tool_data =
      Tool |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    tool_data_with_preloads = paginated_tool_data.entries |> Repo.preload(preloads)

    %{
      entries: tool_data_with_preloads,
      page_number: paginated_tool_data.page_number,
      page_size: paginated_tool_data.page_size,
      total_entries: paginated_tool_data.total_entries,
      total_pages: paginated_tool_data.total_pages
    }
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
