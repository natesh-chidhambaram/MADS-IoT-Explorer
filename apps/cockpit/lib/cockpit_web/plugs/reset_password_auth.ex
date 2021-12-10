defmodule CockpitWeb.ResetPasswordAuth do
  @moduledoc false
  import Plug.Conn

  alias Cockpit.Account

  @spec init(any) :: any
  def init(default), do: default

  def call(conn, _params) do
    conn.params
    |> Map.has_key?("token")
    |> sanitize_token(conn)
    |> Account.validate_token()
    |> verify_token(conn)
  end

  defp sanitize_token(true, conn), do: conn.params["token"]
  defp sanitize_token(false, conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
    |> String.trim("Bearer")
    |> String.trim(" ")
  end

  defp verify_token({:error, _message}, conn) do
    conn
    |> put_status(401)
  end

  defp verify_token({:ok, resource}, conn) do
    assign(conn, :current_user, resource)
  end
end
