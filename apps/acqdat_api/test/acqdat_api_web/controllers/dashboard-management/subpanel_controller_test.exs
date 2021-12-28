defmodule AcqdatApiWeb.DashboardManagement.SubpanelControllerTest do
  @moduledoc """
    subpanel controller uses panel model to save subpanel as reference of panel
    means panel table referencing it self to save subpanel.
  """

  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  setup :setup_conn

  describe "create/2" do
    test "Return sucess when subpanel created successfully", %{conn: conn, org: org} do
      dashboard = insert(:dashboard)
      panel = insert(:panel)
      params = %{name: "test_panel_1", icon: "home"}

      resp =
        conn
        |> post(Routes.subpanel_path(conn, :create, org.id, dashboard.id, panel.id), params)
        |> json_response(200)

      assert resp["panel_id"] == panel.id
      assert resp["dashboard_id"] == dashboard.id
      assert resp["org_id"] == org.id
      assert resp["name"] == "test_panel_1"
      assert Map.has_key?(resp, "id")
    end

    test "Return error when duplicate name is used during create subpanel", %{conn: conn} do
      panel = insert(:panel)
      org_id = panel.org.id
      dashboard_id = panel.dashboard.id
      params = %{name: panel.name, icon: "home"}

      result =
        conn
        |> post(Routes.subpanel_path(conn, :create, org_id, dashboard_id, panel.id), params)
        |> json_response(400)

      assert result == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["unique panel name under dashboard"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "Return error in case bearer token is invalid", %{conn: conn, org: org} do
      panel = insert(:panel)
      bad_access_token = "qwerty1234567uiop"
      conn = put_req_header(conn, "authorization", "Bearer #{bad_access_token}")

      result =
        conn
        |> post(Routes.subpanel_path(conn, :create, org.id, 1, panel.id), %{})
        |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "Return error in case required parameter is missing", %{conn: conn, org: org} do
      panel = insert(:panel)
      dashboard = insert(:dashboard)

      resp =
        conn
        |> post(Routes.subpanel_path(conn, :create, org.id, dashboard.id, panel.id), %{})
        |> json_response(400)

      assert resp == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["can't be blank"], "icon" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end

  describe "show/2" do
    setup do
      [subpanel: insert(:subpanel)]
    end

    test "Success: when subpanel id is valid", %{conn: conn, subpanel: subpanel} do
      resp =
        conn
        |> get(
          Routes.subpanel_path(
            conn,
            :show,
            subpanel.org_id,
            subpanel.dashboard_id,
            subpanel.parent_id,
            subpanel.id
          )
        )
        |> json_response(200)

      refute is_nil(resp)
      assert resp["panel_id"] == subpanel.parent_id
      assert resp["dashboard_id"] == subpanel.dashboard_id
      assert resp["org_id"] == subpanel.org_id
      assert resp["name"] == subpanel.name
    end

    test "Error: when subpanel id is invalid", %{conn: conn, subpanel: subpanel} do
      resp =
        conn
        |> get(
          Routes.subpanel_path(
            conn,
            :show,
            subpanel.org_id,
            subpanel.dashboard_id,
            subpanel.parent_id,
            -1
          )
        )
        |> json_response(400)

      assert resp == %{
               "source" => nil,
               "status_code" => 400,
               "detail" => "panel with this id not found",
               "title" => "not_found"
             }
    end
  end

  describe "index/2" do
    test "Returns all subpanels when correct parameter is passed", %{conn: conn, org: org} do
      subpanel = insert(:subpanel)
      params = %{"page_size" => 100, "page_number" => 1}

      resp =
        conn
        |> get(
          Routes.subpanel_path(
            conn,
            :index,
            org.id,
            subpanel.dashboard_id,
            subpanel.parent_id,
            params
          )
        )
        |> json_response(200)

      assert length(resp["subpanels"]) == 1
      assert resp["subpanels"] |> hd() |> is_map()
    end

    test "Returns error when panel has no subpanel", %{conn: conn, org: org} do
      subpanel = insert(:subpanel)

      resp =
        conn
        |> get(
          Routes.subpanel_path(
            conn,
            :index,
            org.id,
            subpanel.dashboard_id,
            0,
            %{}
          )
        )
        |> json_response(400)

      assert resp == %{
               "detail" => "No subpanel for this panel",
               "source" => nil,
               "status_code" => 400,
               "title" => "not_found"
             }
    end
  end

  describe "update/2" do
    setup do
      [subpanel: insert(:subpanel)]
    end

    test "Return updated subpanel when correct id is given", %{conn: conn, subpanel: subpanel} do
      params = %{name: "updated subpanel name"}

      resp =
        conn
        |> put(
          Routes.subpanel_path(
            conn,
            :update,
            subpanel.org_id,
            subpanel.dashboard_id,
            subpanel.parent_id,
            subpanel.id
          ),
          params
        )
        |> json_response(200)

      refute resp["name"] == subpanel.name
      assert resp["name"] == "updated subpanel name"
    end

    test "Return error when subpanel id is invalid", %{conn: conn, subpanel: subpanel} do
      params = %{name: "updated subpanel name"}

      resp =
        conn
        |> put(
          Routes.subpanel_path(
            conn,
            :update,
            subpanel.org_id,
            subpanel.dashboard_id,
            subpanel.parent_id,
            0
          ),
          params
        )
        |> json_response(404)

      assert resp == %{
               "detail" => "Panel with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "delete/2" do
    setup do
      [subpanel: insert(:subpanel)]
    end

    test "Return success once subpanel is deleted", %{conn: conn, subpanel: subpanel} do
      resp =
        conn
        |> delete(
          Routes.subpanel_path(
            conn,
            :delete,
            subpanel.org_id,
            subpanel.dashboard_id,
            subpanel.parent_id,
            subpanel.id
          )
        )
        |> json_response(200)

      assert resp == %{"status" => "deleted"}
    end

    test "Return error in deleting if invalid id is given", %{conn: conn, subpanel: subpanel} do
      resp =
        conn
        |> delete(
          Routes.subpanel_path(
            conn,
            :delete,
            subpanel.org_id,
            subpanel.dashboard_id,
            subpanel.parent_id,
            -1
          )
        )
        |> json_response(404)

      assert resp == %{
               "detail" => "Panel with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end
end
