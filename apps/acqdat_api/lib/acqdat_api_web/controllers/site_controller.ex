defmodule AcqdatApiWeb.SiteController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Site
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.Model.Site, as: SiteModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Site

  plug :load_site when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, site}} = {:list, SiteModel.get(id)}

        conn
        |> put_status(200)
        |> render("site.json", site)

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
        {:list, site} = {:list, SiteModel.get_all(data, [:devices, :processes])}

        conn
        |> put_status(200)
        |> render("index.json", site)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    params = Map.put(params, "image_url", "")

    changeset =
      case is_nil(params["image"]) do
        true ->
          verify_site_params(params)

        false ->
          params = add_image_url(conn, params)
          verify_site_params(params)
      end

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, site}} <- {:create, Site.create(data)} do
      conn
      |> put_status(200)
      |> render("site.json", %{site: site})
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
        %{assigns: %{site: site}} = conn
        params = Map.put(params, "image_url", site.image_url)

        params =
          case is_nil(params["image"]) do
            true ->
              params

            false ->
              add_image_url(conn, params)
          end

        case SiteModel.update(site, params) do
          {:ok, site} ->
            conn
            |> put_status(200)
            |> render("site.json", %{site: site})

          {:error, site} ->
            error = extract_changeset_error(site)

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
        case SiteModel.delete(id) do
          {:ok, site} ->
            ImageDeletion.delete_operation(site, "site")

            conn
            |> put_status(200)
            |> render("site.json", %{site: site})

          {:error, site} ->
            error = extract_changeset_error(site)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "site"}) do
      Map.replace!(params, "image_url", Image.url({image_name, "site"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end

  defp load_site(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case SiteModel.get(id) do
      {:ok, site} ->
        assign(conn, :site, site)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
