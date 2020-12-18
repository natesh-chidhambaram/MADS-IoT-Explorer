defmodule AcqdatCore.Model.RoleManagement.UserPolicy do
  @moduledoc """
  Models a user policy in acqdat.
  """

  alias AcqdatCore.Schema.RoleManagement.UserPolicy
  alias AcqdatCore.Repo

  def create(params) do
    changeset = UserPolicy.changeset(%UserPolicy{}, params)
    Repo.insert(changeset)
  end
end
