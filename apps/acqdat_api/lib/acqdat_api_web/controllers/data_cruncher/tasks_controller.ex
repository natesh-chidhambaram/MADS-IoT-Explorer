defmodule AcqdatApiWeb.DataCruncher.TasksController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DataCruncher.Tasks
  alias AcqdatApi.DataCruncher.Task
  alias AcqdatApiWeb.DataCruncher.DataCruncherErrorHelper
  alias AcqdatCore.Repo

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadTask when action in [:delete]

  def create(conn, params) do
    case conn.status do
      nil ->
        case Task.create(params) do
          {:ok, task} ->
            conn
            |> put_status(200)
            |> render("task.json", %{task: task})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, DataCruncherErrorHelper.error_message(:tasks, :resource_not_found))

      401 ->
        conn
        |> send_error(401, DataCruncherErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        case Task.update(params) do
          {:ok, task} ->
            task = task |> Repo.preload(workflows: :temp_output)

            conn
            |> put_status(200)
            |> render("task.json", %{task: task})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, DataCruncherErrorHelper.error_message(:tasks, :resource_not_found))

      401 ->
        conn
        |> send_error(401, DataCruncherErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, tasks} = {:list, Task.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", tasks)

      404 ->
        conn
        |> send_error(404, DataCruncherErrorHelper.error_message(:tasks, :resource_not_found))

      401 ->
        conn
        |> send_error(401, DataCruncherErrorHelper.error_message(:unauthorized))
    end
  end

  def show(conn, %{"id" => task_id}) do
    case conn.status do
      nil ->
        {task_id, _} = Integer.parse(task_id)

        case Task.get(task_id) do
          {:error, _} ->
            conn
            |> send_error(400, DataCruncherErrorHelper.error_message(:tasks, :resource_not_found))

          {:ok, task} ->
            conn
            |> put_status(200)
            |> render("task.json", %{task: task})
        end

      404 ->
        conn
        |> send_error(404, DataCruncherErrorHelper.error_message(:tasks, :resource_not_found))

      401 ->
        conn
        |> send_error(401, DataCruncherErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case Task.delete(conn.assigns.task) do
          {:ok, task} ->
            conn
            |> put_status(200)
            |> render("task.json", %{task: task})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)

            conn
            |> send_error(400, error)

          {:error, error} ->
            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, DataCruncherErrorHelper.error_message(:tasks, :resource_not_found))

      401 ->
        conn
        |> send_error(401, DataCruncherErrorHelper.error_message(:unauthorized))
    end
  end
end
