defmodule AcqdatApiWeb.RoleManagement.UserView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.UserView
  alias AcqdatApiWeb.RoleManagement.RoleView
  alias AcqdatApiWeb.EntityManagement.OrganisationView
  alias AcqdatCore.Schema.RoleManagement.Role
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Repo
  alias AcqdatApiWeb.RoleManagement.RoleView
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel

  def render("user_creation.json", %{message: message}) do
    %{
      status: message
    }
  end

  def render("user_details.json", %{
        user_details: %{user_credentials: user_credentials} = user_details
      }) do
    %{
      id: user_details.id,
      email: user_credentials.email,
      first_name: user_credentials.first_name,
      last_name: user_credentials.last_name,
      image: user_credentials.avatar,
      is_invited: user_details.is_invited,
      phone_number: user_credentials.phone_number,
      role_id: user_details.role_id,
      avatar: user_credentials.avatar,
      user_credentials_id: user_credentials.id,
      metadata: user_credentials.metadata && Map.from_struct(user_credentials.metadata),
      role: render_one(preload_role(user_details.role_id), RoleView, "role.json"),
      org:
        render_one(
          preload_org(user_details.org_id),
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("user_update.json", %{
        user_details: %{user_credentials: user_credentials} = user_details
      }) do
    %{
      id: user_details.id,
      email: user_credentials.email,
      first_name: user_credentials.first_name,
      last_name: user_credentials.last_name,
      image: user_credentials.avatar,
      is_invited: user_details.is_invited,
      phone_number: user_credentials.phone_number,
      role_id: user_details.role_id,
      avatar: user_credentials.avatar,
      user_credentials_id: user_credentials.id,
      metadata: user_credentials.metadata && Map.from_struct(user_credentials.metadata),
      role: render_one(preload_role(user_details.role_id), RoleView, "role.json"),
      user_group: render_many(user_details.user_group, UserView, "user_group.json"),
      org:
        render_one(
          preload_org(user_details.org_id),
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("user_index.json", %{user: %{user_credentials: user_credentials} = user_details}) do
    %{
      id: user_details.id,
      email: user_credentials.email,
      first_name: user_credentials.first_name,
      last_name: user_credentials.last_name,
      image: user_credentials.avatar,
      is_invited: user_details.is_invited,
      phone_number: user_credentials.phone_number,
      role_id: user_details.role_id,
      avatar: user_credentials.avatar,
      user_credentials_id: user_credentials.id,
      role: render_one(user_details.role, RoleView, "role.json"),
      user_group: render_many(user_details.user_group, UserView, "user_group.json"),
      policies: render_many(user_details.policies, UserView, "user_policy.json"),
      org:
        render_one(
          user_details.org,
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("index.json", user_details) do
    %{
      users: render_many(user_details.entries, UserView, "user_index.json"),
      page_number: user_details.page_number,
      page_size: user_details.page_size,
      total_entries: user_details.total_entries,
      total_pages: user_details.total_pages
    }
  end

  def render("user_credentials.json", %{user: user_credentials}) do
    %{
      user_credentials_id: user_credentials.id,
      email: user_credentials.email,
      first_name: user_credentials.first_name,
      last_name: user_credentials.last_name,
      phone_number: user_credentials.phone_number,
      metadata: user_credentials.metadata && Map.from_struct(user_credentials.metadata),
      avatar: user_credentials.avatar
    }
  end

  def render("hits.json", %{hits: hits}) do
    user_ids = extract_ids(hits.hits)
    users = UserModel.get_for_view(user_ids)

    %{
      users: render_many(users, UserView, "source.json"),
      total_entries: hits.total.value
    }
  end

  def render("index_hits.json", user) do
    %{
      users: render_many(user.entries, UserView, "source.json"),
      page_number: user.page_number,
      page_size: user.page_size,
      total_entries: user.total_entries,
      total_pages: user.total_pages
    }
  end

  def render("source.json", %{user: user_details}) do
    %{
      id: user_details.id,
      email: user_details.user_credentials.email,
      first_name: user_details.user_credentials.first_name,
      last_name: user_details.user_credentials.last_name,
      is_invited: user_details.is_invited,
      phone_number: user_details.user_credentials.phone_number,
      role_id: user_details.role_id,
      role: render_one(user_details.role, RoleView, "role.json"),
      user_group: render_many(user_details.user_group, UserView, "user_group.json"),
      policies: render_many(user_details.policies, UserView, "user_policy.json"),
      org:
        render_one(
          user_details.org,
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("user_group.json", %{user: user}) do
    group = user.user_group |> Repo.preload(:policies)

    %{
      id: group.id,
      name: group.name,
      policies: render_many(group.policies, UserView, "policy.json")
    }
  end

  def render("policy.json", %{user: policy}) do
    %{
      id: policy.id,
      action: policy.action,
      app: policy.app,
      feature: policy.feature
    }
  end

  def render("user_policy.json", %{user: policies}) do
    policy = policies.policy

    %{
      id: policy.id,
      action: policy.action,
      app: policy.app,
      feature: policy.feature
    }
  end

  def render("user_assets.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      assets: render_many(user.assets, UserView, "asset.json")
    }
  end

  def render("asset.json", asset) do
    %{
      type: "Asset",
      id: asset.user.id,
      name: asset.user.name,
      properties: asset.user.properties
    }
  end

  def render("user_apps.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      apps: render_many(user.apps, UserView, "app.json")
    }
  end

  def render("app.json", app) do
    %{
      id: app.user.id,
      name: app.user.name,
      description: app.user.description
    }
  end

  defp preload_role(id) do
    Map.from_struct(Repo.get(Role, id))
  end

  defp preload_org(id) do
    Map.from_struct(Repo.get(Organisation, id))
  end

  defp extract_ids(hits) do
    Enum.reduce(hits, [], fn %{_source: hits}, acc ->
      acc ++ [hits.id]
    end)
  end
end
