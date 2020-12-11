defmodule AcqdatCore.Schema.RoleManagement.Policy do
  @moduledoc """
  Models a policy in acqdat for a group.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation

  @type t :: %__MODULE__{}

  schema("acqdat_policies") do
    field(:name, :string, null: false)

    embeds_many :actions, Action, on_replace: :delete do
      field(:app, :string, null: false)
      field(:feature, :string, null: false)
      field(:action, :string, null: false)
    end

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @permitted ~w(name org_id)a
  @permitted_actions ~w(app feature action)a

  def changeset(policy, params) do
    policy
    |> cast(params, @permitted)
    |> cast_embed(:actions, with: &action_changeset/2)
    |> validate_required(@permitted)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> unique_constraint(:name,
      name: :acqdat_policies_name_org_id_index,
      message: "unique policy name under organisation"
    )
  end

  defp action_changeset(schema, params) do
    schema
    |> cast(params, @permitted_actions)
    |> validate_required(@permitted_actions)
  end
end
