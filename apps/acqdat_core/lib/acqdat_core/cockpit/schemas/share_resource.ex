defmodule AcqdatCore.Cockpit.Schemas.ShareResource do
  @moduledoc """
  Schemas for share resources by MADS user
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Cockpit.Schemas.User, as: CockpitUser
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Schema.EntityManagement.Organisation

  @keys ~w(type resource_id uuid slug org_id share_by_id cockpit_user_id)a

  schema("acqdat_share_resources") do
    field(:type, :integer, null: false)
    field(:resource_id, :integer, null: false)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)

    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:share_by, User, on_replace: :delete)
    belongs_to(:cockpit_user, CockpitUser, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  def share_changeset(%__MODULE__{} = cockpit_user, params) do
    cockpit_user
    |> cast(params, @keys)
    |> add_slug()
    |> add_uuid()
    |> validate_required(@keys)
    |> unique_constraint(:name,
    name: :acqdat_share_resources_type_resource_id_cockpit_user_id_index,
    message: "Already shared!"
  )
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset),
    do: put_change(changeset, :uuid, UUID.uuid1(:hex))

  defp add_slug(%Ecto.Changeset{valid?: true} = changeset),
    do: put_change(changeset, :slug, Slugger.slugify(random_string(12)))

  defp random_string(length),
    do: :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
end
