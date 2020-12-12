defmodule AcqdatCore.Model.RoleManagement.Group do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  alias AcqdatCore.Schema.RoleManagement.Group
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Group.changeset(%Group{}, params)
    Repo.insert(changeset)
  end
end
