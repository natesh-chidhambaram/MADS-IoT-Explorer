defmodule CockpitWeb.AuthController do
  use CockpitWeb, :controller

  import Cockpit.Validations.Authentication
  import Cockpit.ChangesetHelper

  alias Cockpit.Models.User

  def registration(conn, registration_data) do
    with changeset <- validate_registration_credentials(registration_data),
         {:valid, params} <- fragment_changeset(changeset.valid?, changeset),
         {:ok, _user} <- User.registration(params) do

      # TODO: Need to handle at view level
      send_resp(conn, 200, Poison.encode!(%{status: "success"}))
    else
      {:error, errors} ->
        # TODO: Need to handle at view level
        send_resp(conn, 400, Poison.encode!(errors))
    end
  end
end
