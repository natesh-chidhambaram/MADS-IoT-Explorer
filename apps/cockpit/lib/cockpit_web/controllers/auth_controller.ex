defmodule CockpitWeb.AuthController do
  use CockpitWeb, :controller

  import Cockpit.Validations.Authentication
  import CockpitWeb.Helpers

  alias Cockpit.Models.User

  def registration(conn, registration_data) do
    with changeset <- validate_registration_credentials(registration_data),
         {:valid, params} <- fragment_changeset(changeset.valid?, changeset),
         {:ok, _user} <- User.registration(params) do
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
         {:ok, result} <- User.sign_in(params) do
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
        render_error(conn, 403, "login_error.json", %{error: reason})
    end
  end
end
