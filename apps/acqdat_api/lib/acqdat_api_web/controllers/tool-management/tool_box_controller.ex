defmodule AcqdatApiWeb.ToolManagement.ToolBoxController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.ToolManagement.ToolBox
  alias AcqdatCore.Model.ToolManagement.ToolBox, as: ToolBoxModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.ToolManagement.ToolBox

  plug :load_tool_box when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, tool_box}} = {:list, ToolBoxModel.get(id)}

        conn
        |> put_status(200)
        |> render("tool_box.json", %{tool_box: tool_box})

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
        {:list, tool_box} = {:list, ToolBoxModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", tool_box)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    changeset = verify_tool_box_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, tool_box}} <- {:create, ToolBox.create(data)} do
      conn
      |> put_status(200)
      |> render("tool_box.json", %{tool_box: tool_box})
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
        %{assigns: %{tool_box: tool_box}} = conn

        case ToolBoxModel.update(tool_box, params) do
          {:ok, tool_box} ->
            conn
            |> put_status(200)
            |> render("tool_box.json", %{tool_box: tool_box})

          {:error, tool_box} ->
            error = extract_changeset_error(tool_box)

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
        case ToolBoxModel.delete(id) do
          {:ok, tool_box} ->
            conn
            |> put_status(200)
            |> render("tool_box.json", %{tool_box: tool_box})

          {:error, tool_box} ->
            error = extract_changeset_error(tool_box)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_tool_box(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case ToolBoxModel.get(id) do
      {:ok, tool_box} ->
        assign(conn, :tool_box, tool_box)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
