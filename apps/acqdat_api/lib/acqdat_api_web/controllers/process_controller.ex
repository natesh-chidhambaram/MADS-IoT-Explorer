defmodule AcqdatApiWeb.ProcessController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Process
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.Model.Process, as: ProcessModel
  alias AcqdatCore.Model.Site, as: SiteModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Process

  plug :load_site when action in [:create]
  plug :load_process when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, process}} = {:list, ProcessModel.get(id)}

        conn
        |> put_status(200)
        |> render("process.json", process)

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
        {:list, process} = {:list, ProcessModel.get_all(data, [:site])}

        conn
        |> put_status(200)
        |> render("index.json", process)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        params = Map.put(params, "image_url", "")

        changeset =
          case is_nil(params["image"]) do
            true ->
              verify_process_params(params)

            false ->
              params = add_image_url(conn, params)
              verify_process_params(params)
          end

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, process}} <- {:create, Process.create(data)} do
          conn
          |> put_status(200)
          |> render("process.json", %{process: process})
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

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "process"}) do
      Map.replace!(params, "image_url", Image.url({image_name, "process"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{process: process}} = conn
        params = Map.put(params, "image_url", process.image_url)

        params =
          case is_nil(params["image"]) do
            true ->
              params

            false ->
              add_image_url(conn, params)
          end

        case ProcessModel.update(process, params) do
          {:ok, process} ->
            conn
            |> put_status(200)
            |> render("process.json", %{process: process})

          {:error, process} ->
            error = extract_changeset_error(process)

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
        case ProcessModel.delete(id) do
          {:ok, process} ->
            ImageDeletion.delete_operation(process, "process")

            conn
            |> put_status(200)
            |> render("process.json", %{process: process})

          {:error, process} ->
            error = extract_changeset_error(process)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_site(
         %{params: %{"site_id" => site_id}} = conn,
         _params
       ) do
    {site_id, _} = Integer.parse(site_id)

    case SiteModel.get(site_id) do
      {:ok, site} ->
        assign(conn, :site, site)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_process(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case ProcessModel.get(id) do
      {:ok, process} ->
        assign(conn, :process, process)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
