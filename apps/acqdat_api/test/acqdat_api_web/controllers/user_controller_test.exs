defmodule AcqdatApiWeb.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      [org: org]
    end

    test "fails if authorization header not found", context do
      %{org: org, conn: conn} = context
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.user_path(conn, :show, org.id, 1))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "user with invalid organisation id", context do
      %{org: org, conn: conn} = context
      conn = get(conn, Routes.user_path(conn, :show, org.id, -1))
      result = conn |> json_response(400)
      assert result == %{"errors" => %{"message" => "not found"}}
    end

    test "user with valid id", context do
      %{org: org, conn: conn} = context
      user = insert(:user)

      params = %{
        id: user.id
      }

      conn = get(conn, Routes.user_path(conn, :show, org.id, params.id))
      result = conn |> json_response(200)

      assert result["id"] == user.id
    end
  end
end
