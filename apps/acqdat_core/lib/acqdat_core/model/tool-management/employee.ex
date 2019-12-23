defmodule AcqdatCore.Model.ToolManagement.Employee do
  @moduledoc """
  Exposes APIs to interact with employee DB table.
  """

  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.{Employee, ToolIssue}
  import Ecto.Query

  def create(params) do
    changeset = Employee.create_changeset(%Employee{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Employee, id) do
      nil ->
        {:error, "not found"}

      employee ->
        {:ok, employee}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Employee, query) do
      nil ->
        {:error, "not found"}

      employee ->
        {:ok, employee}
    end
  end

  def update(employee, params) do
    changeset = Employee.update_changeset(employee, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(Employee)
  end

  @spec employee_tool_issue_status(non_neg_integer) :: [ToolIssue]
  def employee_tool_issue_status(employee_id) do
    query =
      from(tool_issue in ToolIssue,
        where: tool_issue.employee_id == ^employee_id and fragment("
            NOT EXISTS(
              SELECT 1
              FROM acqdat_tm_tool_return as tr
              WHERE tr.employee_id = ? and
              tr.tool_issue_id = ?
            )
            ", ^employee_id, tool_issue.id),
        preload: [:tool],
        select: tool_issue
      )

    query |> Repo.all() |> Enum.map(fn tool_issue -> tool_issue.tool end)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Employee
    |> order_by(:id)
    |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def delete(id) do
    Employee
    |> Repo.get(id)
    |> Repo.delete()
  end
end
