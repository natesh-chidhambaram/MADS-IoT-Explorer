defmodule AcqdatApiWeb.IotManager.GatewayController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.IotManager.Gateway
  alias AcqdatApi.IotManager.Gateway
  alias AcqdatApi.Image
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.ElasticSearch
  alias AcqdatApiWeb.IotManager.GatewayErrorHelper
  alias AcqdatCore.Model.IotManager.GatewayDataDump

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject when action not in [:all_gateways, :fetch_projects]
  plug :put_view, AcqdatApiWeb.EntityManagement.ProjectView when action in [:fetch_projects]
  plug :put_view, AcqdatApiWeb.EntityManagement.EntityView when action in [:fetch_project_tree]

  plug AcqdatApiWeb.Plug.LoadGateway
       when action in [
              :update,
              :delete,
              :show,
              :store_commands,
              :associate_sensors,
              :data_dump_index,
              :delete_data_dump,
              :data_dump_error_index
            ]

  plug :load_hierarchy_tree_with_gateway when action in [:hierarchy]
  plug :load_hierarchy_tree when action in [:fetch_project_tree]

  def search_gateways(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_gateways(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, GatewayErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.gateway_indexing(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, GatewayErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def mapped_sensors(conn, %{"org_id" => org_id, "project_id" => project_id}) do
    case conn.status do
      nil ->
        data =
          Gateway.return_sensor_gatewap_mapping(org_id, project_id)
          |> Gateway.extract_param_uuid()

        conn |> put_status(200) |> render("mapped_sensors.json", %{data: data})

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{gateway: gateway}} = conn
        params = Map.put(params, "image_url", gateway.image_url)
        params = extract_image(conn, gateway, params)

        case Gateway.update(gateway, params) do
          {:ok, gateway} ->
            Task.start_link(fn ->
              ElasticSearch.update_gateway("pro", gateway)
            end)

            tree_mapping = Gateway.tree_mapping(gateway.mapped_parameters)
            gateway = Map.put_new(gateway, :tree_mapping, tree_mapping)

            conn
            |> put_status(200)
            |> render("show.json", %{gateway: gateway})

          {:error, error} ->
            response =
              case is_map(error.error) do
                false -> error
                true -> error.error
              end

            send_error(conn, 400, response)
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        params = add_image_to_params(conn, params)
        changeset = verify_gateway(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, gateway}} <- {:create, Gateway.create(data)} do
          Task.start_link(fn ->
            ElasticSearch.insert_gateway("pro", gateway)
          end)

          tree_mapping = Gateway.tree_mapping(gateway.mapped_parameters)
          gateway = Map.put_new(gateway, :tree_mapping, tree_mapping)

          conn
          |> put_status(200)
          |> render("show.json", %{gateway: gateway})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            response =
              case is_map(message.error) do
                false -> message
                true -> message.error
              end

            send_error(conn, 400, response)
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        gateway = conn.assigns.gateway
        gateway = Gateway.load_associations(gateway)
        tree_mapping = Gateway.tree_mapping(gateway.mapped_parameters)
        gateway = Map.put_new(gateway, :tree_mapping, tree_mapping)

        conn
        |> put_status(200)
        |> render("show.json", %{gateway: gateway})

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def hierarchy(conn, _params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        conn
        |> put_status(200)
        |> render("organisation_tree.json", org)

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{gateway: gateway}} = conn

        case Gateway.delete(gateway) do
          {:ok, gateway} ->
            gateway = Map.put(gateway, :image_url, gateway.image_url)

            if gateway.image_url != nil do
              ImageDeletion.delete_operation(gateway.image_url, "gateway")
            end

            Task.start_link(fn ->
              ElasticSearch.delete_data("pro", gateway)
            end)

            conn
            |> put_status(200)
            |> render("delete.json", %{gateway: gateway})

          {:error, gateway} ->
            error = extract_changeset_error(gateway)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def store_commands(conn, params) do
    case conn.status do
      nil ->
        gateway = conn.assigns.gateway
        channel = conn.assigns.gateway.channel
        Gateway.setup_config(gateway, channel, params)

        conn
        |> put_status(200)
        |> json(%{"command_set" => true})

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def associate_sensors(conn, %{"sensor_ids" => sensor_ids}) do
    case conn.status do
      nil ->
        gateway = Gateway.preload_sensor(conn.assigns.gateway)

        case Gateway.associate_sensors(gateway, sensor_ids) do
          {:ok, _message} ->
            gateway = Gateway.load_associations(conn.assigns.gateway)
            tree_mapping = Gateway.tree_mapping(gateway.mapped_parameters)
            gateway = Map.put_new(gateway, :tree_mapping, tree_mapping)

            conn
            |> put_status(200)
            |> render("show.json", %{gateway: gateway})

          {:error, message} ->
            conn
            |> send_error(400, message)
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def all_gateways(conn, params) do
    case conn.status do
      nil ->
        gateways = Gateway.get_by_org(params["org_id"])

        conn
        |> put_status(200)
        |> render("all_gateways.json", gateways: gateways)

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_projects(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.project_indexing(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, GatewayErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_project_tree(conn, _params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        conn
        |> put_status(200)
        |> render("organisation_tree.json", org)

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def delete_data_dump(conn, params) do
    case conn.status do
      nil ->
        params = add_uuid(conn, params)

        case GatewayDataDump.delete_data_dumps(:data_dump, params) do
          {0, nil} ->
            conn
            |> put_status(200)
            |> json(%{no_date: "Data doesn't exists in the selected timeframe"})

          {_integer, nil} ->
            conn
            |> put_status(200)
            |> json(%{success: "Data deleted successfully"})

          _ ->
            conn
            |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))
        end

      404 ->
        conn
        |> send_error(404, GatewayErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, GatewayErrorHelper.error_message(:unauthorized))
    end
  end

  def data_dump_index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        data = add_meta(conn, data)
        {:list, data_dump} = {:list, GatewayDataDump.get_all(data, [:org, :project])}

        conn
        |> put_status(200)
        |> render("data_dump_index.json", data_dump)

      404 ->
        conn
        |> send_error(403, "Unauthorized")
    end
  end

  def data_dump_error_index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        data = add_meta(conn, data)
        {:list, data_dump} = {:list, GatewayDataDump.get_all_error(data)}

        conn
        |> put_status(200)
        |> render("data_dump_error_index.json", data_dump)

      404 ->
        conn
        |> send_error(403, "Unauthorized")
    end
  end

  ############################### private functions #########################

  defp add_image_to_params(conn, params) do
    params = Map.put(params, "image_url", "")

    case is_nil(params["image"]) do
      true ->
        params

      false ->
        add_image_url(conn, params)
    end
  end

  defp extract_image(conn, gateway, params) do
    case is_nil(params["image"]) do
      true ->
        params

      false ->
        if gateway.image_url != nil do
          ImageDeletion.delete_operation(gateway.image_url, "gateway")
        end

        add_image_url(conn, params)
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "gateway"}) do
      Map.replace!(params, "image_url", Image.url({image_name, "gateway"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end

  defp load_hierarchy_tree(
         %{params: %{"org_id" => org_id, "project_id" => project_id}} = conn,
         _params
       ) do
    check_org(conn, org_id, project_id)
  end

  defp check_org(conn, org_id, project_id) do
    {org_id, _} = Integer.parse(org_id)
    {project_id, _} = Integer.parse(project_id)

    case OrgModel.get(org_id, project_id) do
      {:ok, org} ->
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_hierarchy_tree_with_gateway(
         %{params: %{"org_id" => org_id, "project_id" => project_id}} = conn,
         _params
       ) do
    check_org_with_gateway(conn, org_id, project_id)
  end

  defp check_org_with_gateway(conn, org_id, project_id) do
    {org_id, _} = Integer.parse(org_id)
    {project_id, _} = Integer.parse(project_id)

    case OrgModel.get(org_id, project_id) do
      {:ok, org} ->
        org = GModel.fetch_hierarchy_data(org, org_id, project_id)
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  def gateway_error_index(conn, params) do
    changeset = verify_error_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, errors} = {:list, GatewayDataDump.get_error(data, [:gateway])}

        conn
        |> put_status(200)
        |> render("error_index.json", errors)

      404 ->
        conn
        |> send_error(403, "Unauthorized")
    end
  end

  def sensor_error_index(conn, params) do
    changeset = verify_sensor_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, errors} = {:list, GatewayDataDump.get_sensor_error(data, [:sensor])}

        conn
        |> put_status(200)
        |> render("error_index.json", errors)

      404 ->
        conn
        |> send_error(403, "Unauthorized")
    end
  end

  defp add_meta(conn, data) do
    data
    |> Map.put(:org_uuid, conn.assigns.org.uuid)
    |> Map.put(:project_uuid, conn.assigns.project.uuid)
    |> Map.put(:gateway_uuid, conn.assigns.gateway.uuid)
  end

  defp add_uuid(conn, data) do
    data
    |> Map.put("org_uuid", conn.assigns.org.uuid)
    |> Map.put("project_uuid", conn.assigns.project.uuid)
    |> Map.put("gateway_uuid", conn.assigns.gateway.uuid)
  end
end
