defmodule AcqdatApiWeb.DeviceController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.Device
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.Model.Device, as: DeviceModel
  alias AcqdatCore.Model.Site, as: SiteModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Device

  plug :load_device when action in [:update, :delete, :show]
  plug :load_site when action in [:device_by_criteria, :create]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, device} = {:list, DeviceModel.get_all(data, [:site])}

        conn
        |> put_status(200)
        |> render("index.json", device)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, device}} = {:list, DeviceModel.get(id)}

        conn
        |> put_status(200)
        |> render("device.json", device)

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
              verify_device_params(params)

            false ->
              params = add_image_url(conn, params)
              verify_device_params(params)
          end

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, device}} <- {:create, Device.create(data)} do
          conn
          |> put_status(200)
          |> render("device.json", %{device: device})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Site Not Found")
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "device"}) do
      Map.replace!(params, "image_url", Image.url({image_name, "device"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{device: device}} = conn
        params = Map.put(params, "image_url", device.image_url)

        params =
          case is_nil(params["image"]) do
            true ->
              params

            false ->
              add_image_url(conn, params)
          end

        case DeviceModel.update(device, params) do
          {:ok, device} ->
            conn
            |> put_status(200)
            |> render("device.json", %{device: device})

          {:error, device} ->
            error = extract_changeset_error(device)

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
        case DeviceModel.delete(id) do
          {:ok, device} ->
            ImageDeletion.delete_operation(device, "device")

            conn
            |> put_status(200)
            |> render("device.json", %{device: device})

          {:error, device} ->
            error = extract_changeset_error(device)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def device_by_criteria(conn, params) do
    case conn.status do
      nil ->
        {:list, device_by_criteria} = Device.device_by_criteria(params)

        conn
        |> put_status(200)
        |> render("device_by_criteria_with_preloads.json",
          device_by_criteria: device_by_criteria
        )

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_device(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case DeviceModel.get(id) do
      {:ok, device} ->
        assign(conn, :device, device)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_site(%{params: %{"site_id" => site_id}} = conn, _params) do
    {site_id, _} = Integer.parse(site_id)

    case SiteModel.get(site_id) do
      {:ok, site} ->
        assign(conn, :site, site)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
