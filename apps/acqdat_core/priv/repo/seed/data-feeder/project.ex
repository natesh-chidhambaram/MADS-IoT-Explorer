defmodule AcqdatCore.Seed.DataFeeder.Project do
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def seed_data!() do
    create_index()
    organisations = Repo.all(Organisation)
    Enum.each(organisations, fn org ->
      insert_organisation("org", org)
    end)
    projects = Repo.all(Project)
    Enum.each(projects, fn project ->
      create_project("org", project)
    end)
  end

  defp create_index() do
    put("/org",%{mappings: %{properties: %{join_field: %{type: "join", relations: %{org: "project"}}}}})
  end

  defp insert_organisation(type, params) do
    post("#{type}/_doc/#{params.id}?refresh=true",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      inserted_at: DateTime.to_unix(params.inserted_at),
      join_field: "org"
      )
  end

  defp create_project(type, params) do
    post("#{type}/_doc/#{params.id}?routing=#{params.org_id}?refresh=true",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      slug: params.slug,
      description: params.description,
      avatar: params.avatar,
      location: params.location,
      archived: params.archived,
      version: params.version,
      start_date: params.start_date,
      creator_id: params.creator_id,
      inserted_at: DateTime.to_unix(params.inserted_at),
      metadata: params.metadata,
      join_field: %{name: "project", parent: params.org_id}
      )
  end

  def seed_gateway() do
    put("/pro",%{mappings: %{properties: %{join_field: %{type: "join", relations: %{pro: ["gateway"]}}}}})
    projects = Repo.all(Project)
    Enum.each(projects, fn project ->
      insert_pro("pro", project)
    end)
    seed_gateway_data()
  end

  defp insert_pro(type, params) do
    post("#{type}/_doc/#{params.id}?refresh=true",
    id: params.id,
    name: params.name,
    uuid: params.uuid,
    slug: params.slug,
    description: params.description,
    avatar: params.avatar,
    location: params.location,
    archived: params.archived,
    version: params.version,
    start_date: params.start_date,
    inserted_at: DateTime.to_unix(params.inserted_at),
    creator_id: params.creator_id,
    metadata: params.metadata,
    join_field: "pro"
    )
  end

  defp seed_gateway_data() do
    gateways = Repo.all(Gateway)
    Enum.each(gateways, fn gateway ->
      insert_gateway("pro", gateway)
    end)
  end

  defp insert_gateway(type, params) do
    post("#{type}/_doc/#{params.id}?routing=#{params.project_id}?refresh=true",
    id: params.id,
    name: params.name,
    uuid: params.uuid,
    slug: params.slug,
    parent_type: params.parent_type,
    parent_id: params.parent_id,
    org_id: params.org_id,
    project_id: params.project_id,
    channel: params.channel,
    image_url: params.image_url,
    inserted_at: DateTime.to_unix(params.inserted_at),
    join_field: %{name: "gateway", parent: params.project_id}
    )
  end
end
