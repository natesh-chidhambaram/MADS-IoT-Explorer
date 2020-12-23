defmodule AcqdatApiWeb.ApiAccess.UserGroupController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.ApiAccess.UserGroup
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.ApiAccess.UserGroup

  # plug :load_group when action in [:show, :update, :delete]

  # def show(conn, _params) do
  #   case conn.status do
  #     nil ->
  #       conn
  #       |> put_status(200)
  #       |> render("group.json", %{group: conn.assigns.group})

  #     404 ->
  #       conn
  #       |> send_error(404, "Resource Not Found")
  #   end
  # end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_group(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, group}} <- {:create, UserGroup.create(data)} do
          conn
          |> put_status(200)
          |> render("user_group.json", %{group: group})
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

  # def update(conn, params) do
  #   case conn.status do
  #     nil ->
  #       case Group.update(conn.assigns.group, params) do
  #         {:ok, group} ->
  #           conn
  #           |> put_status(200)
  #           |> render("group.json", %{group: group})

  #         {:error, group} ->
  #           error = extract_changeset_error(group)

  #           conn
  #           |> send_error(400, error)
  #       end

  #     404 ->
  #       conn
  #       |> send_error(404, "Resource Not Found")
  #   end
  # end

  # def index(conn, params) do
  #   changeset = verify_index_params(params)

  #   case conn.status do
  #     nil ->
  #       {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
  #       {:list, group} = {:list, Group.get_all(data, [])}

  #       conn
  #       |> put_status(200)
  #       |> render("index.json", group)

  #     404 ->
  #       conn
  #       |> send_error(404, "Resource Not Found")
  #   end
  # end

  # def delete(conn, _params) do
  #   case conn.status do
  #     nil ->
  #       case Group.delete(conn.assigns.group) do
  #         {:ok, _group} ->
  #           conn
  #           |> put_status(200)
  #           |> render("group.json", %{group: conn.assigns.group})
  #         {:error, message} ->
  #             error = extract_changeset_error(message)

  #             conn
  #             |> send_error(400, error)
  #       end

  #     404 ->
  #       conn
  #       |> send_error(404, "Resource Not Found")
  #   end
  # end

  # defp load_group(%{params: %{"id" => id}} = conn, _params) do
  #   {id, _} = Integer.parse(id)

  #   case Group.get(id) do
  #     {:ok, group} ->
  #       assign(conn, :group, group)

  #     {:error, _message} ->
  #       conn
  #       |> put_status(404)
  #   end
  # end
end
