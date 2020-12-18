defmodule AcqdatCore.Schema.RoleManagement.UserPolicy do
  @moduledoc """
  Models a group in acqdat.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{Policy, User}

  @type t :: %__MODULE__{}

  schema("acqdat_user_policies") do
    # associations
    belongs_to(:user, User, on_replace: :delete)
    belongs_to(:policy, Policy)
  end

  @required ~w(user_id policy_id)a
  @permitted @required

  def changeset(user_policy, params) do
    user_policy
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> assoc_constraint(:user)
    |> assoc_constraint(:policy)
    |> unique_constraint(:user_id,
      name: :acqdat_user_policies_user_id_policy_id_index,
      message: "unique policy for a user"
    )
  end
end
