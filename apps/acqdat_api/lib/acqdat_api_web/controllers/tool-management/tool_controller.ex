defmodule AcqdatApiWeb.ToolManagement.ToolController do
  use AcqdatApiWeb, :controller
  alias AcqdatCore.Model.ToolManagement.Tool, as: ToolModel
  alias AcqdatApi.ToolManagement.Tool
  alias AcqdatCore.Model.ToolManagement.ToolType, as: ToolTypeModel
  alias AcqdatCore.Model.ToolManagement.ToolBox, as: ToolBoxModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.ToolManagement.Tool

  plug :load_tool_type_and_tool_box when action in [:create]
  plug :load_tool when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, tool}} = {:list, ToolModel.get(id)}

        conn
        |> put_status(200)
        |> render("tool.json", %{tool: tool})

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
        {:list, tool} = {:list, ToolModel.get_all(data, [:tool_type, :tool_box])}

        conn
        |> put_status(200)
        |> render("index.json", tool)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_tool_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, tool}} <- {:create, Tool.create(data)} do
          conn
          |> put_status(200)
          |> render("tool_for_create.json", %{tool: tool})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{tool: tool}} = conn

        case ToolModel.update(tool, params) do
          {:ok, tool} ->
            conn
            |> put_status(200)
            |> render("tool.json", %{tool: tool})

          {:error, tool} ->
            error = extract_changeset_error(tool)

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
        case ToolModel.delete(id) do
          {:ok, tool} ->
            conn
            |> put_status(200)
            |> render("tool_for_create.json", %{tool: tool})

          {:error, tool} ->
            error = extract_changeset_error(tool)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_tool(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case ToolModel.get(id) do
      {:ok, tool} ->
        assign(conn, :tool, tool)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_tool_type_and_tool_box(
         %{params: %{"tool_type_id" => tool_type_id, "tool_box_id" => tool_box_id}} = conn,
         _params
       ) do
    {tool_type_id, _} = Integer.parse(tool_type_id)
    {tool_box_id, _} = Integer.parse(tool_box_id)

    case ToolBoxModel.get(tool_box_id) do
      {:ok, tool_box} ->
        case ToolTypeModel.get(tool_type_id) do
          {:ok, tool_type} ->
            tool_type = Map.put(tool_type, :tool_box, tool_box)
            assign(conn, :tool_type, tool_type)

          {:error, _message} ->
            conn
            |> put_status(404)
        end

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
