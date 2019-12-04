defmodule AcqdatApiWeb.NotificationPolicyControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "index/2" do
    setup :setup_conn

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.notification_policy_path(conn, :index))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "listing policies", %{conn: conn} do
      conn = get(conn, Routes.notification_policy_path(conn, :index))
      result = conn |> json_response(200)
      assert Map.has_key?(result, "policies")
      %{"policies" => [policy_list]} = result
      assert Map.has_key?(policy_list, "policy_name")
      assert Map.has_key?(policy_list, "preferences_name")
      assert Map.has_key?(policy_list, "rule_data")
      assert Map.has_key?(policy_list, "rule_name")
    end
  end
end
