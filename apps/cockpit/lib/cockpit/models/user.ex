defmodule Cockpit.Models.User do
  @moduledoc """
  Service module to perform database CRUD operations.
  """

  alias AcqdatCore.Repo
  alias Cockpit.Schemas.User

  def registration(params) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end
end
