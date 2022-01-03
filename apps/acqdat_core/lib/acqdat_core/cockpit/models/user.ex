defmodule AcqdatCore.Cockpit.Models.User do
  @moduledoc """
  Service module to perform database CRUD operations for cockpit users.
  """

  alias AcqdatCore.Repo
  alias AcqdatCore.Cockpit.Schemas.User

  def initiate(email) do
    %User{}
    |> User.initial_changeset(%{
      first_name: hd(String.split(email, "@")),
      email: email,
      password: random_string(8)
    })
    |> Repo.insert()
  end

  def register(params) do
    params[:email]
    |> get_user_by_email()
    |> insert_or_update(params)
  end

  defp insert_or_update(nil, params) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end

  defp insert_or_update(user, params) when user.status == "init",
    do: update(user, params)

  defp insert_or_update(_, _),
    do: {:error, %{title: "Invalid request", errors: %{email: "has already been taken"}}}

  def update(user, params) do
    user
    |> User.update_changeset(params)
    |> Repo.update()
  end

  def password_reset(current_user, params) do
    current_user
    |> User.reset_password_changeset(params)
    |> Repo.update()
  end

  def get_user_by_email(email), do: Repo.get_by(User, email: email)
  def get_user_by_uuid(uuid), do: Repo.get_by(User, uuid: uuid)

  defp random_string(length),
    do: :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
end
