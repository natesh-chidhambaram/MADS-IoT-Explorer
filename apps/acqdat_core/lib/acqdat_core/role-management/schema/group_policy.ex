defmodule AcqdatCore.Schema.RoleManagement.GroupPolicy do
  @moduledoc """
  Models a group in acqdat.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{Policy, UserGroup}

  @type t :: %__MODULE__{}

  schema("acqdat_group_policies") do
    # associations
    belongs_to(:user_group, UserGroup, on_replace: :delete)
    belongs_to(:policy, Policy)
  end

  @required ~w(user_group_id policy_id)a
  @permitted @required

  def changeset(group, params) do
    group
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> assoc_constraint(:user_group)
    |> assoc_constraint(:policy)
    |> unique_constraint(:user_group_id,
      name: :acqdat_group_policies_user_group_id_policy_id_index,
      message: "unique policy under one group"
    )
  end
end
