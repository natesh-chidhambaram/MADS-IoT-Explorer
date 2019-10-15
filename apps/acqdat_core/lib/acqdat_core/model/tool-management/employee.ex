defmodule AcqdatCore.Model.ToolManagement.Employee do
  @moduledoc """
  Exposes APIs to interact with employee DB table.
  """

  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.Employee

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

  def delete(id) do
    Employee
    |> Repo.get(id)
    |> Repo.delete()
  end
end
