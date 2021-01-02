defmodule AcqdatCore.Model.RoleManagement.UserGroup do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.RoleManagement.UserGroup
  alias AcqdatCore.Repo

  def create(params) do
    changeset = UserGroup.changeset(%UserGroup{}, params)
    Repo.insert(changeset)
  end

  def extract_groups(ids) do
    query =
      from(group in UserGroup,
        where: group.id in ^ids,
        select: group.id
      )

    Repo.all(query)
  end
end
