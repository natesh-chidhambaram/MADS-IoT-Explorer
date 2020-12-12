defmodule AcqdatCore.Schema.RoleManagement.GroupUser do
  @moduledoc """
  Models a group in acqdat.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{User, Group}

  @type t :: %__MODULE__{}

  schema("acqdat_group_users") do
    # associations
    belongs_to(:group, Group, on_replace: :delete)
    belongs_to(:user, User, on_replace: :delete)
  end

  @required ~w(user_id group_id)a
  @permitted @required

  def changeset(group, params) do
    group
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> assoc_constraint(:group)
    |> assoc_constraint(:user)
    |> unique_constraint(:group_id,
      name: :acqdat_group_users_group_id_user_id_index,
      message: "unique user under one group"
    )
  end
end
