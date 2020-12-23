defmodule AcqdatCore.Model.RoleManagement.UserGroup do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  alias AcqdatCore.Schema.RoleManagement.UserGroup
  alias AcqdatCore.Repo

  def create(params) do
    changeset = UserGroup.changeset(%UserGroup{}, params)
    Repo.insert(changeset)
  end
end
