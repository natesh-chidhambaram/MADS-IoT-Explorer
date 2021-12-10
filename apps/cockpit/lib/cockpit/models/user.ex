defmodule Cockpit.Models.User do
  @moduledoc """
  Service module to perform database CRUD operations.
  """

  alias AcqdatCore.Repo
  alias Cockpit.Schemas.User

  def register_user(params) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end

  def password_reset(current_user, params) do
    current_user
    |> User.reset_password_changeset(params)
    |> Repo.update()
  end

  def get_user_by_email(email), do: Repo.get_by(User, email: email)
  def get_user_by_uuid(uuid), do: Repo.get_by(User, uuid: uuid)
end
