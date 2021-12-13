defmodule Cockpit.Account do
  @moduledoc """
  Module to handle authentication related operations
  """

  alias Cockpit.Models.User
  alias Comeonin.Argon2
  alias CockpitWeb.Guardian
  alias Cockpit.Email
  alias Cockpit.Mailer

  @base_url Application.get_env(:cockpit, :cockpit_url)
  @access_time_hours_login Application.get_env(:cockpit, :access_time_hours_login)
  @access_time_hours_forgot_pass Application.get_env(:cockpit, :access_time_hours_forgot_pass)
  @refresh_time_weeks Application.get_env(:cockpit, :refresh_time_weeks)

  def registration(params) do
    params
    |> Map.put(:status, "active")
    |> User.register_user()
  end

  def sign_in(%{email: email, password: password}) do
    email
    |> User.get_user_by_email()
    |> verify_user_credentials(password)
    |> case do
      {:ok, user} ->
        {access_token, refresh_token} = get_jwt_tokens(user)

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

  def reset_password(current_user, password),
    do: User.password_reset(current_user, %{password: password})

  def validate_user_by_email(email) do
    with current_user <- User.get_user_by_email(email),
         false <- is_nil(current_user),
         true <- is_active?(current_user.status) do
      {:ok, current_user}
    else
      _ -> {:error, :not_found}
    end
  end

  def send_reset_password_email(user) do
    {:ok, email_token, _} =
      create_jwt_token(user, {sanitize_data(@access_time_hours_forgot_pass), :hours}, :access)

    reset_password_url = generate_reset_password_url(email_token)

    user
    |> Email.send_password_email(reset_password_url)
    |> Mailer.deliver_later()

    {:ok, %{success: true}}
  end

  def validate_token(token) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user_uuid} <- Guardian.resource_from_claims(claims),
         current_user <- User.get_user_by_uuid(user_uuid),
         false <- is_nil(current_user) do
      {:ok, current_user}
    else
      _ -> {:error, :unauthorized}
    end
  end

  ###################### private functions ###########################

  defp is_active?("active"), do: true
  defp is_active?(_), do: false

  defp generate_reset_password_url(email_token),
    do: @base_url <> "reset_password?token=" <> email_token

  defp verify_user_credentials(nil, _), do: {:error, "Invalid email or password"}
  defp verify_user_credentials(user, password), do: is_user_active(user.status, password)

  def is_user_active("active", user, password),
    do: validate_password(user, Argon2.checkpw(password, user.password_hash))

  def is_user_active(_, _, _), do: {:error, "Invalid email or password"}

  defp validate_password(user, true), do: {:ok, user}
  defp validate_password(_user, _), do: {:error, "Invalid email or password"}

  defp get_jwt_tokens(user) do
    {:ok, access_token, _} =
      create_jwt_token(user, {sanitize_data(@access_time_hours_login), :hours}, :access)

    {:ok, refresh_token, _} =
      create_jwt_token(user, {sanitize_data(@refresh_time_weeks), :weeks}, :refresh)

    {access_token, refresh_token}
  end

  defp create_jwt_token(resource, time, token_type) do
    Guardian.encode_and_sign(
      resource,
      %{},
      token_type: token_type,
      ttl: time
    )
  end

  defp sanitize_data(data), do: String.to_integer(data)
end
