defmodule AcqdatApiWeb.DigitalTwin.TabController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.DigitalTwin.Tab
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.DigitalTwin.Model.Tab, as: TabModel
  alias AcqdatApiWeb.DigitalTwin.TabErrorHelper
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
        |> send_error(404, TabErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TabErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
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
        |> send_error(404, TabErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TabErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{tab: tab}} = conn

        case tab.image_url do
          nil -> update_image(conn, tab, params)
          _already_uploaded -> extract_image(conn, tab, params)
        end

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
        |> send_error(404, TabErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TabErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        case TabModel.delete(id) do
          {:ok, tab} ->
            if tab.image_url != nil do
              ImageDeletion.delete_operation(
                tab.image_url,
                "org/#{tab.org_id}/digital_twin/#{tab.digital_twin_id}/tab/#{tab.id}"
              )
            end

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
        |> send_error(404, TabErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TabErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, TabErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TabErrorHelper.error_message(:unauthorized))
    end
  end

  ############################# private methods #########################
  defp update_image(conn, tab, params) do
    image_url =
      if is_nil(params["image"]), do: "", else: upload_and_fetch_url(conn, params, tab.id)

    Tab.update(tab, %{"image_url" => image_url})
  end

  defp upload_and_fetch_url(
         conn,
         %{"image" => image, "digital_twin_id" => digital_twin_id, "org_id" => org_id} = params,
         tab_id
       ) do
    scope = "org/#{org_id}/digital_twin/#{digital_twin_id}/tab/#{tab_id}"

    with {:ok, image_name} <- Image.store({image, scope}) do
      Image.url({image_name, scope})
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end

  defp extract_image(
         conn,
         tab,
         %{"digital_twin_id" => digital_twin_id, "org_id" => org_id} = params
       ) do
    params = params |> parse_metadata_params()

    case is_nil(params["image"]) do
      true ->
        params

      false ->
        if tab.image_url != nil do
          ImageDeletion.delete_operation(
            tab.image_url,
            "org/#{org_id}/digital_twin/#{digital_twin_id}/tab/#{tab.id}"
          )
        end

        add_image_url(conn, params, tab.id)
    end
  end

  defp parse_metadata_params(%{"metadata" => metadata} = params) do
    metadata =
      case Poison.decode(metadata) do
        {:ok, data} ->
          data

        _ ->
          []
      end

    Map.put(params, "metadata", metadata)
  end

  defp parse_metadata_params(params) do
    params
  end

  defp add_image_url(
         conn,
         %{"image" => image, "digital_twin_id" => digital_twin_id, "org_id" => org_id} = params,
         entity_id
       ) do
    scope = "org/#{org_id}/digital_twin/#{digital_twin_id}/tab/#{entity_id}"

    with {:ok, image_name} <- Image.store({image, scope}) do
      Map.replace!(params, "image_url", Image.url({image_name, scope}))
    else
      {:error, error} -> send_error(conn, 400, error)
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
