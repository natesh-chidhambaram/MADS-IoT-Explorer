defmodule AcqdatCore.Schema.RoleManagement.Policy do
  @moduledoc """
  Models a policy in acqdat for a group.
  """

  use AcqdatCore.Schema
  @type t :: %__MODULE__{}

  schema("acqdat_policies") do
    field(:app, :string, null: false)
    field(:feature, :string, null: false)
    field(:action, :string, null: false)

    timestamps(type: :utc_datetime)
  end

  @permitted ~w(app feature action)a

  def changeset(policy, params) do
    policy
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> unique_constraint(:name,
      name: :acqdat_policies_app_feature_action_index,
      message: "unique action per feature per app"
    )
  end
end
