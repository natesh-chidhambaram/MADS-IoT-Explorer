defmodule AcqdatApiWeb.EntityManagement.ProjectControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      user = insert(:user)
      [org: org, user: user]
    end

    test "project create", %{conn: conn, org: org, user: user} do
      project = build(:project)

      data = %{
        name: project.name,
        creator_id: user.id
      }

      conn = post(conn, Routes.project_path(conn, :create, org.id), data)
      response = conn |> json_response(200)

      assert response["name"] == project.name
      assert response["creator_id"] == user.id
      assert response["org_id"] == org.id
    end

    test "fails if authorization header not found", %{conn: conn, org: org, user: user} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{
        creator_id: user.id
      }

      conn = post(conn, Routes.project_path(conn, :create, org.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if sent params are not unique", %{conn: conn} do
      project = insert(:project)

      data = %{
        name: project.name,
        creator_id: project.creator_id
      }

      conn = post(conn, Routes.project_path(conn, :create, project.org_id), data)
      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["unique name under organisation"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "fails if required params are missing", %{conn: conn, org: org} do
      conn = post(conn, Routes.project_path(conn, :create, org.id), %{})
      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end

  describe "archived/2" do
    setup :setup_conn

    test "Project Data", %{conn: conn} do
      test_project = insert(:project, archived: true)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn =
        get(conn, Routes.archived_projects_path(conn, :archived, test_project.org_id, params))

      response = conn |> json_response(200)
      assert length(response["projects"]) == 1
      assertion_project = List.first(response["projects"])
      assert assertion_project["id"] == test_project.id
      assert assertion_project["archived"] == test_project.archived
      assert assertion_project["description"] == test_project.description
      assert assertion_project["name"] == test_project.name
      assert assertion_project["org_id"] == test_project.org_id
      assert assertion_project["slug"] == test_project.slug
    end

    test "if params are missing", %{conn: conn, org: org} do
      insert_list(3, :project, archived: true)
      conn = get(conn, Routes.archived_projects_path(conn, :archived, org.id, %{}))
      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["projects"]) == response["total_entries"]
    end

    test "Big page size", %{conn: conn, org: org} do
      insert_list(3, :project, archived: true)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.archived_projects_path(conn, :archived, org.id, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["projects"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      [project1, _project2, _project3] = insert_list(3, :project, archived: true)

      params = %{
        "page_size" => 1,
        "page_number" => 1
      }

      conn = get(conn, Routes.archived_projects_path(conn, :archived, project1.org_id, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 1
      assert length(page1_response["projects"]) == page1_response["page_size"]
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.archived_projects_path(conn, :archived, org.id, params))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "project update", %{conn: conn} do
      project = insert(:project)
      data = Map.put(%{}, :name, "Water Project")

      conn = put(conn, Routes.project_path(conn, :update, project.org_id, project.id), data)
      response = conn |> json_response(200)

      assert response["name"] == data.name
      assert response["id"] == project.id
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty12345678qwer"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Project")
      conn = put(conn, Routes.project_path(conn, :update, project.org_id, project.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "project delete", %{conn: conn} do
      project = insert(:project)

      conn = delete(conn, Routes.project_path(conn, :delete, project.org_id, project.id))
      response = conn |> json_response(200)

      assert response["id"] == project.id
    end

    test "fails if project has associated asset_types", %{conn: conn} do
      asset_type = insert(:asset_type)

      conn =
        delete(conn, Routes.project_path(conn, :delete, asset_type.org_id, asset_type.project_id))

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Asset Types are attached to this project. This is a restricted action.",
               "source" => "asset_types are attached to this project",
               "status_code" => 400,
               "title" => "Asset Type attachment constraint"
             }
    end

    test "fails if project has associated sensor_types", %{conn: conn} do
      sensor_type = insert(:sensor_type)

      conn =
        delete(
          conn,
          Routes.project_path(conn, :delete, sensor_type.org_id, sensor_type.project_id)
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Sensor Types are attached to this project. This is a restricted action.",
               "source" => "sensor_types are attached to this project",
               "status_code" => 400,
               "title" => "Sensor Type attachment constraint"
             }
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      project = insert(:project)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.project_path(conn, :delete, project.org_id, project.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "fetch_count/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      asset = insert(:asset)
      sensor = insert(:sensor)
      asset_type = insert(:asset_type)
      sensor_type = insert(:sensor_type)

      [
        project: project,
        asset: asset,
        sensor: sensor,
        asset_type: asset_type,
        sensor_type: sensor_type
      ]
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = post(conn, Routes.project_path(conn, :fetch_count), %{})
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "shows asset count per project", %{conn: conn, asset: asset} do
      params = %{type: "Asset", project_id: asset.project_id}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] == 1

      conn = post(conn, Routes.project_path(conn, :fetch_count), %{type: "Asset", project_id: -1})
      result = conn |> json_response(200)

      assert result["count"] == 0
    end

    test "shows all the assets count", %{conn: conn} do
      params = %{type: "Asset"}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] >= 1
    end

    test "shows asset_type count per project", %{conn: conn, asset_type: asset_type} do
      params = %{type: "AssetType", project_id: asset_type.project_id}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] == 1

      conn =
        post(conn, Routes.project_path(conn, :fetch_count), %{type: "AssetType", project_id: -1})

      result = conn |> json_response(200)

      assert result["count"] == 0
    end

    test "shows all asset_type count", %{conn: conn} do
      params = %{type: "AssetType"}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] >= 1
    end

    test "shows sensor count per project", %{conn: conn, sensor: sensor} do
      params = %{type: "Sensor", project_id: sensor.project_id}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] == 1

      conn =
        post(conn, Routes.project_path(conn, :fetch_count), %{type: "Sensor", project_id: -1})

      result = conn |> json_response(200)

      assert result["count"] == 0
    end

    test "shows all sensors count", %{conn: conn} do
      params = %{type: "Sensor"}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] >= 1
    end

    test "shows all sensor_types count", %{conn: conn} do
      params = %{type: "SensorType"}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] >= 1
    end

    test "shows sensor_type count per project", %{conn: conn, sensor_type: sensor_type} do
      params = %{type: "SensorType", project_id: sensor_type.project_id}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] >= 1
    end

    test "shows project count", %{conn: conn} do
      params = %{type: "Project"}
      conn = post(conn, Routes.project_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] >= 1
    end
  end
end
