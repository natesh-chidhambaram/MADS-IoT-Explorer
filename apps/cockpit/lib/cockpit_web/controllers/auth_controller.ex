defmodule CockpitWeb.AuthController do
  use CockpitWeb, :controller

  import Cockpit.Validations.Authentication
  import CockpitWeb.Helpers

  alias Cockpit.Account

  def registration(conn, registration_data) do
    with changeset <- validate_registration_credentials(registration_data),
         {:valid, params} <- fragment_changeset(changeset.valid?, changeset),
         {:ok, _user} <- Account.registration(params) do
      conn
      |> put_status(200)
      |> render("register.json", %{status: :success})
    else
      {:invalid, errors} ->
        render_error(conn, 400, "error.json", errors)

      {:error, errors = %Ecto.Changeset{}} ->
        errors = fragment_error_changeset(errors, "Invalid request")
        render_error(conn, 400, "error.json", errors)
    end
  end

  def sign_in(conn, signin_data) do
    with changeset <- validate_signin_credentials(signin_data),
         {:valid, params} <- fragment_changeset(changeset.valid?, changeset),
         {:ok, result} <- Account.sign_in(params) do
      conn
      |> put_status(200)
      |> render("signin.json", result)
    else
      {:invalid, errors} ->
        render_error(conn, 400, "error.json", errors)

      {:error, errors = %Ecto.Changeset{}} ->
        errors = fragment_error_changeset(errors, "Invalid request")
        render_error(conn, 403, "error.json", errors)

      {:error, reason} ->
        render_error(conn, 403, "auth_error.json", %{error: reason})
    end
  end

  def forgot_password(conn, user_email) do
    with changeset <- validate_email(user_email),
         {:valid, %{email: email}} <- fragment_changeset(changeset.valid?, changeset),
         {:ok, user} <- Account.validate_user_by_email(email),
         {:ok, %{success: true}} <- Account.send_reset_password_email(user) do
      conn
      |> put_status(200)
      |> render("forgot_password.json", %{status: :mail_sent})
    else
      {:invalid, errors} ->
        render_error(conn, 400, "error.json", errors)

      {:error, reason} ->
        render_error(conn, 403, "auth_error.json", %{error: reason})
    end
  end

  def reset_password(conn, %{"password" => password}) do
    with nil <- conn.status,
    current_user <- conn.assigns.current_user,
    {:ok, _current_user} <- Account.reset_password(current_user, password) do
      conn
      |> put_status(200)
      |> render("reset_password.json", %{status: :success})
    else
      401 ->
        render_error(conn, 400, "auth_error.json", %{error: :unauthorized})

      {:error, errors = %Ecto.Changeset{}} ->
        errors = fragment_error_changeset(errors, "Auth error")
        render_error(conn, 403, "error.json", errors)

      {:error, reason} ->
        render_error(conn, 403, "auth_error.json", %{error: reason})
    end
  end
end
