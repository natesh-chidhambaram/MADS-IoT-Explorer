defmodule Cockpit.Models.User do
  @moduledoc """
  Service module to perform database CRUD operations.
  """

  alias AcqdatCore.Repo
  alias Cockpit.Schemas.User
  alias Comeonin.Argon2
  alias CockpitWeb.Guardian

  @access_time_hours 10
  @refresh_time_weeks 7

  def registration(params) do
    %User{}
    |> User.registration_changeset(params)
    |> Repo.insert()
  end

  def sign_in(%{email: email, password: password}) do
    User
    |> Repo.get_by(email: email)
    |> verify_user_credentials(password)
    |> case do
      {:ok, user} ->
        {:ok, access_token, _claims} =
          create_jwt_token(user, {@access_time_hours, :hours}, :access)

        {:ok, refresh_token, _claims} =
          create_jwt_token(user, {@refresh_time_weeks, :weeks}, :refresh)

        {:ok,
         %{
           email: email,
           credentials_id: user.uuid,
           access_token: access_token,
           refresh_token: refresh_token
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  ###################### private functions ###########################

  defp verify_user_credentials(nil, _), do: {:error, "Invalid email or password"}

  defp verify_user_credentials(user, password),
    do: validate_password(user, Argon2.checkpw(password, user.password_hash))

  defp validate_password(user, true), do: {:ok, user}
  defp validate_password(_user, _), do: {:error, "Invalid email or password"}

  defp create_jwt_token(resource, time, token_type) do
    Guardian.encode_and_sign(
      resource,
      %{},
      token_type: token_type,
      ttl: time
    )
  end
end
