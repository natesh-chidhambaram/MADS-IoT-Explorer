defmodule AcqdatIotWeb.DataDump do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  use AcqdatIotWeb.ConnCase
  import Plug.Conn
  alias AcqdatCore.Test.Support.DataDump

  describe "create/2" do
    setup %{} do
      # Setting the shared mode so the internal processes share the same db
      # conneciton.
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end

    setup :setup_gateway

    test "data dump create", %{conn: conn, gateway: gateway, data_dump: data_dump} do
      params = data_dump

      conn =
        post(
          conn,
          Routes.data_dump_path(conn, :create, gateway.org_id, gateway.project_id, gateway.id),
          params
        )

      # TODO: have added a small time out so worker processes release db
      # connection, else the test exits and db connection is removed.
      # Need to add a clean way to handle this.
      :timer.sleep(50)
      result = conn |> json_response(202)
      assert result == %{"data inserted" => true}
    end

    test "data dump create with utc timestamp", %{
      conn: conn,
      gateway: gateway,
      data_dump: data_dump
    } do
      params = data_dump

      params =
        Map.replace!(
          params,
          "timestamp",
          DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()
        )

      conn =
        post(
          conn,
          Routes.data_dump_path(conn, :create, gateway.org_id, gateway.project_id, gateway.id),
          params
        )

      # TODO: have added a small time out so worker processes release db
      # connection, else the test exits and db connection is removed.
      # Need to add a clean way to handle this.
      :timer.sleep(50)
      result = conn |> json_response(202)
      assert result == %{"data inserted" => true}
    end

    test "fails if authorization header not found", %{conn: conn, gateway: gateway} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn =
        post(
          conn,
          Routes.data_dump_path(conn, :create, gateway.org_id, gateway.project_id, gateway.id),
          data
        )

      result = conn |> json_response(404)

      assert result == %{
               "errors" => %{
                 "message" => %{
                   "error" => "You are not allowed to perform this action.",
                   "source" => nil,
                   "title" => "Unauthorized Access"
                 }
               }
             }
    end
  end

  def setup_gateway(%{conn: conn}) do
    [data_dump, _sensor1, _sensor2, gateway] = DataDump.setup_gateway()

    data_dump = data_dump.data

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{gateway.access_token}")

    [conn: conn, gateway: gateway, data_dump: data_dump]
  end
end
