defmodule AcqdatCore.Model.IotManager.Gateway do
  import Ecto.Query
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SModel
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel
  alias AcqdatCore.Model.EntityManagement.Asset, as: AModel
  alias AcqdatCore.Model.EntityManagement.Project, as: PModel
  alias AcqdatCore.Model.IotManager.MQTT.BrokerCredentials
  alias AcqdatCore.Model.IotManager.MQTTBroker
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo
  alias Ecto.Multi

  @doc """
  Creates a gateway with the supplied params.

  The gateway can send data over two different channels `http` and `mqtt`.
  The two channels need different kinds of setup. For mqtt a subscription would
  be started per project in case it's not already present. Also, we need to
  setup broker credentials for gateway, so the authentication flow can be performed
  by broker before allowing any communication to happen.
  """
  def create(params) do
    Multi.new()
    |> Multi.run(:insert_gateway, fn _, _changes ->
      changeset = Gateway.changeset(%Gateway{}, params)
      Repo.insert(changeset)
    end)
    |> Multi.run(:setup_mqtt_if_needed, fn _, changes ->
      %{insert_gateway: gateway} = changes
      setup_credentials(gateway)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{setup_mqtt_if_needed: data}} ->
        {:ok, data.gateway}

      {:error, _failed_operation, failed_value, _} ->
        {:error, failed_value}
    end
  end

  def return_mapped_parameter(gateway_id) do
    gateway = Repo.get(Gateway, gateway_id)
    gateway.mapped_parameters
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Gateway, id) do
      nil ->
        {:error, "Gateway not found"}

      gateway ->
        {:ok, gateway}
    end
  end

  def get(id) when is_integer(id) do
    case Repo.get(Gateway, id) do
      nil ->
        {:error, "Gateway not found"}

      gateway ->
        {:ok, gateway}
    end
  end

  def get_gateways(gateway_ids) when is_list(gateway_ids) do
    from(gateway in Gateway,
      where: gateway.id in ^gateway_ids
    )
    |> Repo.all()
  end

  def get(data) when is_map(data) do
    case Repo.get_by(Gateway, data) do
      nil ->
        {:error, "Gateway not found"}

      gateway ->
        {:ok, Repo.preload(gateway, [:org, :project])}
    end
  end

  def get_names_by_ids(gateway_ids) when is_list(gateway_ids) do
    from(gateway in Gateway,
      where: gateway.id in ^gateway_ids,
      select: %{
        id: gateway.id,
        name: gateway.name
      }
    )
    |> Repo.all()
  end

  def child_gateways(root) do
    child_gateways_query(root)
    |> Repo.all()
  end

  def child_gateways_query(root) when not is_list(root) do
    from(gateway in Gateway,
      where: gateway.parent_id == ^root.id and gateway.parent_type == "Asset"
    )
  end

  def child_gateways_query(asset_ids) when is_list(asset_ids) do
    from(gateway in Gateway,
      where: gateway.parent_id in ^asset_ids and gateway.parent_type == "Asset"
    )
  end

  def update(%Gateway{} = gateway, params) do
    gateway_channel = gateway.channel

    Multi.new()
    |> Multi.run(:update_gateway, fn _, _changes ->
      update_gateway(gateway, params)
    end)
    |> Multi.run(:setup_mqtt_if_needed, fn _, changes ->
      %{update_gateway: gateway} = changes
      update_channel(gateway, gateway_channel)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{setup_mqtt_if_needed: data}} ->
        {:ok, data.gateway}

      {:error, _failed_operation, failed_value, _} ->
        {:error, failed_value}
    end
  end

  def get_all_if_metadata_present() do
    from(gateway in Gateway,
      where: not is_nil(gateway.mapped_parameters)
    )
    |> Repo.all()
  end

  def associate_gateway_and_sensor() do
    gateways = get_all_if_metadata_present()

    Enum.map(gateways, fn gateway ->
      sensor_ids = extract_sensor_ids_from_parameters(gateway.mapped_parameters)
      associate_sensors(gateway |> Repo.preload([:sensors]), sensor_ids)
    end)
  end

  defp update_gateway(gateway, %{"mapped_parameters" => mapped_parameters} = params) do
    sensor_ids = extract_sensor_ids_from_parameters(mapped_parameters)
    changeset = Gateway.update_changeset(gateway, params)

    case Repo.update(changeset) do
      {:ok, gateway} ->
        GModel.associate_sensors(gateway |> Repo.preload([:sensors]), sensor_ids)
        gateway = Repo.get!(Gateway, gateway.id) |> Repo.preload([:sensors])
        {:ok, gateway}

      {:error, message} ->
        {:error, message}
    end
  end

  defp update_gateway(gateway, params) do
    changeset = Gateway.update_changeset(gateway, params)
    Repo.update(changeset)
  end

  defp extract_sensor_ids_from_parameters(mapped_parameters) do
    Enum.reduce(mapped_parameters, [], fn {_key, value}, acc ->
      filter_from_parameters(value, acc)
    end)
  end

  defp filter_from_parameters(%{"type" => "object", "value" => parameters}, acc) do
    result =
      Enum.reduce(parameters, [], fn {_key, value}, accumulator ->
        filter_from_parameters(value, accumulator)
      end)

    acc ++ result
  end

  defp filter_from_parameters(%{"type" => "list", "value" => value}, acc) do
    ids =
      Enum.reduce(value, [], fn params, acc ->
        case params["type"] do
          "value" -> acc ++ [params["entity_id"]]
          _ -> acc ++ filter_from_parameters(params, acc)
        end
      end)

    acc ++ ids
  end

  defp filter_from_parameters(%{"type" => "value", "entity_id" => entity_id}, acc) do
    [entity_id | acc]
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Gateway |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(
        %{page_size: page_size, page_number: page_number, org_id: org_id, project_id: project_id},
        preloads
      ) do
    query =
      from(gateway in Gateway,
        where: gateway.project_id == ^project_id and gateway.org_id == ^org_id
      )

    paginated_project_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    project_data_with_preloads = paginated_project_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(project_data_with_preloads, paginated_project_data)
  end

  def get_by_org(org_id) do
    query =
      from(
        gateway in Gateway,
        where: gateway.org_id == ^org_id
      )

    Repo.all(query)
  end

  def delete(%{channel: "http"} = gateway) do
    case Repo.delete(gateway) do
      {:ok, gateway} ->
        {:ok, gateway}

      {:error, gateway} ->
        {:error, gateway}
    end
  end

  def delete(%{channel: "mqtt"} = gateway) do
    case Repo.delete(gateway) do
      {:ok, gateway} ->
        BrokerCredentials.delete(gateway.uuid)
        {:ok, gateway}

      {:error, gateway} ->
        {:error, gateway}
    end
  end

  def fetch_gateways(project_id) do
    query =
      from(gateway in Gateway,
        where: gateway.parent_id == ^project_id
      )

    Repo.all(query)
  end

  def fetch_hierarchy_data(org, org_id, project_id) do
    hierarchy = PModel.hierarchy_data_for_gateway(org_id, project_id)
    gateway = get_gateways(project_id)
    org = Map.replace!(org, :project_data, hierarchy)
    Map.put_new(org, :gateway_data, gateway)
  end

  def attach_parent(gateway) do
    {:ok, parent} =
      case gateway.parent_type do
        "Project" -> PModel.get_by_id(gateway.parent_id)
        "Asset" -> AModel.get(gateway.parent_id)
      end

    Map.put_new(gateway, :parent, parent)
  end

  def get_gateways(project_id) do
    gateways = fetch_gateways(project_id)

    gateway_ids = fetch_gateway_ids(gateways)
    sensors = SModel.get_all_by_parent_gateway(gateway_ids)

    Enum.reduce(gateways, [], fn gateway, acc ->
      gateway =
        gateway
        |> attach_parent()
        |> attach_children(sensors)

      acc ++ [gateway]
    end)
  end

  def attach_children(gateway, sensors) do
    child_sensors = Enum.filter(sensors, fn sensor -> sensor.gateway_id == gateway.id end)

    Map.put(gateway, :childs, child_sensors)
  end

  def send_mqtt_config(gateway, payload) do
    time = DateTime.utc_now() |> DateTime.to_unix()
    payload = Map.put(payload, :current_timestamp, time)
    gateway = Repo.preload(gateway, project: :org)
    project = gateway.project
    org = gateway.project.org
    topic = "org/#{org.uuid}/project/#{project.uuid}/gateway/#{gateway.uuid}/config"

    MQTTBroker.publish(project.uuid, topic, Jason.encode!(payload))
  end

  @spec send_mqtt_command(Gateway.t(), map()) ::
          :ok | {:error, :unknown_connection} | {:ok, reference}
  def send_mqtt_command(gateway, payload) do
    gateway = Repo.preload(gateway, project: :org)
    project = gateway.project
    org = gateway.project.org
    topic = "org/#{org.uuid}/project/#{project.uuid}/gateway/#{gateway.uuid}/command"
    MQTTBroker.publish(project.uuid, topic, Jason.encode!(payload))
  end

  @doc """
  Attaching right sensors and updating sensor
  """
  def associate_sensors(gateway, sensor_ids) do
    attached_sensors = MapSet.new(extract_sensor_ids(gateway.sensors))
    requested_sensors = MapSet.new(sensor_ids)
    transaction(gateway, attached_sensors, requested_sensors)
  end

  ##################### private functions #####################

  defp transaction(gateway, attached_sensors, requested_sensors) do
    result =
      Repo.transaction(fn ->
        SModel.remove_sensor(
          MapSet.to_list(MapSet.difference(attached_sensors, requested_sensors))
        )

        SModel.add_sensor(
          MapSet.to_list(MapSet.difference(requested_sensors, attached_sensors)),
          gateway
        )
      end)

    case result do
      {:ok, _message} ->
        {:ok, "Gateway Sensor List updated"}

      {:error, message} ->
        {:error, "Some error occurred while updating list"}
    end
  end

  def modify_mapped_parameters(gateway_ids, detached_sensor_ids) do
    gateways = GModel.get_gateways(gateway_ids)

    Enum.each(gateways, fn gateway ->
      mapped_parameters =
        remove_sensor_from_parameters(gateway.mapped_parameters, detached_sensor_ids)

      GModel.update(gateway, %{mapped_parameters: mapped_parameters})
    end)
  end

  defp remove_sensor_from_parameters(mapped_parameters, detached_sensor_ids) do
    Enum.reduce(mapped_parameters, %{}, fn {key, value}, acc ->
      case filter_for_sensors(value, detached_sensor_ids) do
        nil ->
          acc

        rparams ->
          Map.put_new(acc, key, rparams)
      end
    end)
  end

  defp filter_for_sensors(%{"type" => "object", "value" => parameters}, detached_sensor_ids) do
    value =
      Enum.reduce(parameters, %{}, fn {key, value}, accumulator ->
        case filter_for_sensors(value, detached_sensor_ids) do
          nil ->
            accumulator

          rparams ->
            Map.put_new(accumulator, key, rparams)
        end
      end)

    %{"type" => "object", "value" => value}
  end

  defp filter_for_sensors(%{"type" => "list", "value" => value}, detached_sensor_ids) do
    value =
      Enum.reduce(value, [], fn value, accumulator ->
        case filter_for_sensors(value, detached_sensor_ids) do
          nil -> accumulator
          rparams -> accumulator ++ [rparams]
        end
      end)

    %{"type" => "list", "value" => value}
  end

  defp filter_for_sensors(
         %{"type" => "value", "entity_id" => entity_id} = params,
         detached_sensor_ids
       ) do
    case Enum.member?(detached_sensor_ids, entity_id) do
      true -> nil
      false -> params
    end
  end

  defp extract_sensor_ids(sensors) do
    Enum.reduce(sensors, [], fn sensor, acc ->
      acc ++ [sensor.id]
    end)
  end

  def setup_credentials(gateway) do
    initiation_for_channel(gateway, gateway.channel)
  end

  defp initiation_for_channel(gateway, "http"), do: {:ok, %{gateway: gateway}}

  defp initiation_for_channel(gateway, "mqtt") do
    validate_gateway_creds_results(
      gateway,
      BrokerCredentials.create(gateway, gateway.access_token, "Gateway")
    )
  end

  # adding only gateway credentials
  defp validate_gateway_creds_results(gateway, {:ok, _creds}) do
    {:ok, %{gateway: gateway}}
  end

  defp validate_gateway_creds_results(_gateway, {:error, changeset}) do
    {:error, changeset}
  end

  defp fetch_gateway_ids(gateways) do
    Enum.reduce(gateways, [], fn gateway, acc ->
      acc ++ [gateway.id]
    end)
  end

  defp update_channel(gateway = %{channel: channel}, previous_channel)
       when channel == previous_channel,
       do: {:ok, %{gateway: gateway}}

  defp update_channel(gateway, "mqtt") do
    BrokerCredentials.delete(gateway.uuid)
    {:ok, %{gateway: gateway}}
  end

  defp update_channel(gateway, "http") do
    setup_credentials(gateway)
  end
end
