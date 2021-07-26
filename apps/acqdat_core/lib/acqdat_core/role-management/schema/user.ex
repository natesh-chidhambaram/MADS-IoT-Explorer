defmodule AcqdatCore.Schema.RoleManagement.User do
  @moduledoc """
  Models a user in acqdat.
  """

  use AcqdatCore.Schema
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.{Asset, Organisation}
  alias AcqdatCore.Schema.RoleManagement.UserPolicy
  alias AcqdatCore.Schema.RoleManagement.UserCredentials
  alias AcqdatCore.Schema.RoleManagement.{App, Role, GroupUser}
  alias AcqdatCore.Repo

  @type t :: %__MODULE__{}

  schema("users") do
    field(:is_deleted, :boolean, default: false)
    field(:is_invited, :boolean, default: false)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:user_credentials, UserCredentials)
    belongs_to(:role, Role)
    has_many(:user_group, GroupUser)
    has_many(:policies, UserPolicy)
    many_to_many(:assets, Asset, join_through: "asset_user", on_replace: :delete)
    many_to_many(:apps, App, join_through: "app_user", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(user_credentials_id is_invited role_id org_id)a
  @optional ~w(is_deleted)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> common_changeset(params)
    |> add_apps_changeset(params[:app_ids] || [])
    |> add_assets_changeset(params[:asset_ids] || [])
  end

  def update_changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, @permitted)
    |> common_changeset(params)
  end

  def common_changeset(changeset, _params) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:role)
  end

  defp add_apps_changeset(user, app_ids) do
    apps = Repo.all(from(app in App, where: app.id in ^app_ids))

    user
    |> put_assoc(:apps, Enum.map(apps, &change/1))
  end

  defp add_assets_changeset(user, asset_ids) do
    assets = Repo.all(from(asset in Asset, where: asset.id in ^asset_ids))

    user
    |> put_assoc(:assets, Enum.map(assets, &change/1))
  end

  def associate_asset_changeset(user, assets) do
    user
    |> Repo.preload(:assets)
    |> change()
    |> put_assoc(:assets, assets)
  end

  def associate_app_changeset(user, apps) do
    user
    |> Repo.preload(:apps)
    |> change()
    |> put_assoc(:apps, apps)
  end
end
