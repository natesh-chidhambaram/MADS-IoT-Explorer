defmodule AcqdatApiWeb.ToolManagement.EmployeeController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.ToolManagement.Employee, as: EmployeeModel
  alias AcqdatApi.ToolManagement.Employee
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.ToolManagement.Employee

  plug :load_employee when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, employee}} = {:list, EmployeeModel.get(id)}

        conn
        |> put_status(200)
        |> render("employee.json", %{employee: employee})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, employee} = {:list, EmployeeModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", employee)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    changeset = verify_employee_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, employee}} <- {:create, Employee.create(data)} do
      conn
      |> put_status(200)
      |> render("employee.json", %{employee: employee})
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, message}} ->
        send_error(conn, 400, message)
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{employee: employee}} = conn

        case EmployeeModel.update(employee, params) do
          {:ok, employee} ->
            conn
            |> put_status(200)
            |> render("employee.json", %{employee: employee})

          {:error, employee} ->
            error = extract_changeset_error(employee)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        case EmployeeModel.delete(id) do
          {:ok, employee} ->
            conn
            |> put_status(200)
            |> render("employee.json", %{employee: employee})

          {:error, employee} ->
            error = extract_changeset_error(employee)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_employee(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case EmployeeModel.get(id) do
      {:ok, employee} ->
        assign(conn, :employee, employee)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
