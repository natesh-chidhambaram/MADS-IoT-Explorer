defmodule AcqdatCore.Model.RoleManagement.Policy do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  alias AcqdatCore.Schema.RoleManagement.Policy
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Policy.changeset(%Policy{}, params)
    Repo.insert(changeset)
  end
end
