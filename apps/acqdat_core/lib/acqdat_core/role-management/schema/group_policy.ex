defmodule AcqdatCore.Schema.RoleManagement.GroupPolicy do
  @moduledoc """
  Models a group in acqdat.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{Policy, Group}

  @type t :: %__MODULE__{}

  schema("acqdat_group_policies") do
    # associations
    belongs_to(:group, Group, on_replace: :delete)
    belongs_to(:policy, Policy)
  end

  @required ~w(group_id policy_id)a
  @permitted @required

  def changeset(group, params) do
    group
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> assoc_constraint(:group)
    |> assoc_constraint(:policy)
    |> unique_constraint(:group_id,
      name: :acqdat_group_policies_group_id_policy_id_index,
      message: "unique policy under one group"
    )
  end
end
