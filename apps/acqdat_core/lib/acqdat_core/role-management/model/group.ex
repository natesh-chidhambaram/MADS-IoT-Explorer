defmodule AcqdatCore.Model.RoleManagement.Group do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  alias AcqdatCore.Schema.RoleManagement.Groups
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Groups.changeset(%Groups{}, params)
    Repo.insert(changeset)
  end
end
