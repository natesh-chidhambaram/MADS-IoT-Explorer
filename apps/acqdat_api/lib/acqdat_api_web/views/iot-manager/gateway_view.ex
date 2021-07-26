defmodule AcqdatApiWeb.IotManager.GatewayView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.OrganisationView
  alias AcqdatApiWeb.EntityManagement.ProjectView
  alias AcqdatApiWeb.IotManager.GatewayView
  alias AcqdatApiWeb.EntityManagement.SensorView
  alias AcqdatCore.Repo

  @http_url System.get_env("HTTP_URL") || "https://datakrewtech.com/iot/"

  def render("mapped_sensors.json", %{data: data}) do
    data
  end

  def render("index.json", gateway) do
    %{
      gateways: render_many(gateway.entries, GatewayView, "index_show.json"),
      page_number: gateway.page_number,
      page_size: gateway.page_size,
      total_entries: gateway.total_entries,
      total_pages: gateway.total_pages
    }
  end

  def render("all_gateways.json", %{gateways: gateways}) do
    %{gateways: render_many(gateways, GatewayView, "gist.json")}
  end

  def render("gist.json", %{gateway: gateway}) do
    %{
      uuid: gateway.uuid,
      id: gateway.id,
      name: gateway.name,
      project_id: gateway.project_id,
      org_id: gateway.org_id
    }
  end

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.project_data, ProjectView, "project_including_gateway.json"),
      gateways: render_many(org.gateway_data, GatewayView, "gateway.json")
    }
  end

  def render("show.json", %{gateway: gateway}) do
    %{
      uuid: gateway.uuid,
      type: "Gateway",
      id: gateway.id,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel_details: selective_rendering(gateway),
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      tree_mapping: gateway.tree_mapping,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "streaming_data.json"),
      mapped_parameters: gateway.mapped_parameters,
      current_location: gateway.current_location,
      org_id: gateway.org_id,
      image_url: gateway.image_url,
      org: render_one(gateway.org, OrganisationView, "org.json"),
      project: render_one(gateway.project, ProjectView, "project_gateway.json"),
      sensors: render_many(gateway.sensors, SensorView, "sensor.json"),
      timestamp_mapping: gateway.timestamp_mapping
    }
  end

  def render("index_show.json", %{gateway: gateway}) do
    %{
      uuid: gateway.uuid,
      type: "Gateway",
      id: gateway.id,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel_details: selective_rendering(gateway),
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "streaming_data.json"),
      mapped_parameters: gateway.mapped_parameters,
      current_location: gateway.current_location,
      org_id: gateway.org_id,
      image_url: gateway.image_url,
      org: render_one(gateway.org, OrganisationView, "org.json"),
      project: render_one(gateway.project, ProjectView, "project_gateway.json"),
      sensors: render_many(gateway.sensors, SensorView, "sensor.json"),
      timestamp_mapping: gateway.timestamp_mapping
    }
  end

  def render("delete.json", %{gateway: gateway}) do
    %{
      type: "Gateway",
      uuid: gateway.uuid,
      id: gateway.id,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "streaming_data.json"),
      current_location: gateway.current_location,
      mapped_parameters: gateway.mapped_parameters,
      org_id: gateway.org_id,
      image_url: gateway.image_url,
      timestamp_mapping: gateway.timestamp_mapping
    }
  end

  def render("data.json", %{gateway: data}) do
    %{
      data: data
    }
  end

  def render("gateway.json", %{gateway: gateway}) do
    gateway = Repo.preload(gateway, [:org, :project, :sensors])

    %{
      type: "Gateway",
      id: gateway.id,
      uuid: gateway.uuid,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "streaming_data.json"),
      mapped_parameters: gateway.mapped_parameters,
      current_location: gateway.current_location,
      org_id: gateway.org_id,
      image_url: gateway.image_url,
      org: render_one(gateway.org, OrganisationView, "org.json"),
      project: render_one(gateway.project, ProjectView, "project_gateway.json"),
      parent: render_one(gateway.parent, GatewayView, "parent.json"),
      childs: render_many(gateway.childs, SensorView, "sensor.json"),
      sensors: render_many(gateway.sensors, SensorView, "sensor.json")
    }
  end

  def render("gateway_tree.json", %{gateway: gateway}) do
    gateway = Repo.preload(gateway, [:org, :project, :sensors])

    %{
      type: "Gateway",
      id: gateway.id,
      uuid: gateway.uuid,
      name: gateway.name,
      access_token: gateway.access_token,
      serializer: gateway.serializer,
      channel: gateway.channel,
      parent_id: gateway.parent_id,
      parent_type: gateway.parent_type,
      slug: gateway.slug,
      description: gateway.description,
      static_data: render_many(gateway.static_data, GatewayView, "data.json"),
      streaming_data: render_many(gateway.streaming_data, GatewayView, "streaming_data.json"),
      mapped_parameters: gateway.mapped_parameters,
      current_location: gateway.current_location,
      org_id: gateway.org_id,
      image_url: gateway.image_url
    }
  end

  def render("parent.json", %{gateway: parent}) do
    %{
      id: parent.id,
      name: parent.name,
      uuid: parent.uuid,
      slug: parent.slug
    }
  end

  def render("data_dump_index.json", data_dump) do
    %{
      data_dumps: render_many(data_dump.entries, GatewayView, "data_dump_show.json"),
      page_number: data_dump.page_number,
      page_size: data_dump.page_size,
      total_entries: data_dump.total_entries,
      total_pages: data_dump.total_pages
    }
  end

  def render("data_dump_show.json", %{gateway: data_dump}) do
    %{
      data: data_dump.data,
      gateway_uuid: data_dump.gateway_uuid,
      inserted_timestamp: data_dump.inserted_timestamp
    }
  end

  def render("streaming_data.json", %{gateway: streaming_data}) do
    %{
      data_type: streaming_data.data_type,
      name: streaming_data.name,
      unit: streaming_data.unit,
      uuid: streaming_data.uuid
    }
  end

  def render("hits.json", %{hits: hits}) do
    %{
      gateways: render_many(hits.hits, GatewayView, "source.json"),
      total_entries: hits.total.value
    }
  end

  def render("source.json", %{gateway: %{_source: hits}}) do
    %{
      type: "Gateway",
      uuid: hits.uuid,
      id: hits.id,
      name: hits.name,
      channel: hits.channel,
      parent_id: hits.parent_id,
      parent_type: hits.parent_type,
      slug: hits.slug,
      image_url: hits.image_url
    }
  end

  defp selective_rendering(%{channel: "http"} = gateway) do
    %{
      path: create_url("http", gateway),
      access_token: gateway.access_token
    }
  end

  defp selective_rendering(%{channel: "mqtt"} = gateway) do
    %{
      topic: create_url("mqtt", gateway),
      client_id: gateway.uuid,
      username: gateway.uuid,
      auth_token: gateway.access_token,
      host: System.fetch_env!("MQTT_EXPOSED_HOSTNAME"),
      port: System.fetch_env!("MQTT_EXPOSED_PORT")
    }
  end

  defp create_url("http", gateway) do
    @http_url <>
      "orgs/" <>
      "#{gateway.org_id}" <>
      "/projects/" <> "#{gateway.project.id}" <> "/gateways/" <> "#{gateway.id}" <> "/data_dump"
  end

  defp create_url("mqtt", gateway) do
    "org/" <>
      "#{gateway.org.uuid}" <>
      "/project/" <> "#{gateway.project.uuid}" <> "/gateway/" <> "#{gateway.uuid}"
  end
end
