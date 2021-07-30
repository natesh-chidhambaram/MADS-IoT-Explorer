defmodule AcqdatApiWeb.RoleManagement.ExtractedRoutesControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Repo

  describe "apis/2" do
    setup :setup_conn

    test "returns valid list of apis" do
      params = %{}
      conn = conn |> get(Routes.extracted_routes_path(conn, :apis), params)
      response = conn |> json_response(200)

      assert Map.get(
               Map.get(Map.get(Map.get(response, "routes"), "RoleManagement"), "ExtractedRoutes"),
               "actions"
             ) == %{"apis" => %{"path" => "apis", "request_type" => "get"}}
    end
  end
end
