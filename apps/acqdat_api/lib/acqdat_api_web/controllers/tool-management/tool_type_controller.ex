defmodule AcqdatApiWeb.ToolManagement.ToolTypeController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.ToolManagement.ToolType
  alias AcqdatCore.Model.ToolManagement.ToolType, as: ToolTypeModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.ToolManagement.ToolType

  plug :load_tool_type when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, tool_type}} = {:list, ToolTypeModel.get(id)}

        conn
        |> put_status(200)
        |> render("tool_type.json", %{tool_type: tool_type})

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
        {:list, tool_type} = {:list, ToolTypeModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", tool_type)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    changeset = verify_tool_type_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, tool_type}} <- {:create, ToolType.create(data)} do
      conn
      |> put_status(200)
      |> render("tool_type.json", %{tool_type: tool_type})
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
        %{assigns: %{tool_type: tool_type}} = conn

        case ToolTypeModel.update(tool_type, params) do
          {:ok, tool_type} ->
            conn
            |> put_status(200)
            |> render("tool_type.json", %{tool_type: tool_type})

          {:error, tool_type} ->
            error = extract_changeset_error(tool_type)

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
        case ToolTypeModel.delete(id) do
          {:ok, tool_type} ->
            conn
            |> put_status(200)
            |> render("tool_type.json", %{tool_type: tool_type})

          {:error, tool_type} ->
            error = extract_changeset_error(tool_type)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_tool_type(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case ToolTypeModel.get(id) do
      {:ok, tool_type} ->
        assign(conn, :tool_type, tool_type)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
