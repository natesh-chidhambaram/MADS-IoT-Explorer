defmodule AcqdatCore.Model.RoleManagement.GroupUser do
  @moduledoc """
  Models a user policy in acqdat.
  """

  alias AcqdatCore.Schema.RoleManagement.GroupUser
  alias AcqdatCore.Repo

  def create(params) do
    changeset = GroupUser.changeset(%GroupUser{}, params)
    Repo.insert(changeset)
  end
end
