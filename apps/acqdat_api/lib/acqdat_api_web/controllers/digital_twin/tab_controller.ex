defmodule AcqdatApiWeb.DigitalTwin.TabController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.DigitalTwin.Tab
  alias AcqdatCore.DigitalTwin.Model.Tab, as: TabModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DigitalTwin.Tab

  plug :load_tab when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, tab}} = {:list, TabModel.get(id)}

        conn
        |> put_status(200)
        |> render("tab.json", tab)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    opened_on = DateTime.utc_now()
    params = Map.put_new(params, "opened_on", opened_on)

    case conn.status do
      nil ->
        changeset = verify_tab_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, tab}} <- {:create, Tab.create(data)} do
          conn
          |> put_status(200)
          |> render("tab.json", %{tab: tab})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(
          404,
          "Either Resource Not Found or Process and Site ID are not mutually exclusive or both are missing"
        )
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{tab: tab}} = conn

        case TabModel.update(tab, params) do
          {:ok, tab} ->
            conn
            |> put_status(200)
            |> render("tab.json", %{tab: tab})

          {:error, tab} ->
            error = extract_changeset_error(tab)

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
        case TabModel.delete(id) do
          {:ok, tab} ->
            conn
            |> put_status(200)
            |> render("tab.json", %{tab: tab})

          {:error, tab} ->
            error = extract_changeset_error(tab)

            conn
            |> send_error(400, error)
        end

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
        {:list, tab} = {:list, TabModel.get_all(data, [])}

        conn
        |> put_status(200)
        |> render("index.json", tab)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_tab(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case TabModel.get(id) do
      {:ok, tab} ->
        assign(conn, :tab, tab)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
