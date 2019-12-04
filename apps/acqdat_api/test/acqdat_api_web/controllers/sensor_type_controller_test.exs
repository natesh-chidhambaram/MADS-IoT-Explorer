defmodule AcqdatApiWeb.SensorTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "sensor type create", %{conn: conn} do
      sensor_type_manifest = build(:sensor_type)

      data = %{
        name: sensor_type_manifest.name,
        make: sensor_type_manifest.make,
        visualizer: sensor_type_manifest.visualizer,
        identifier: sensor_type_manifest.identifier,
        value_keys: sensor_type_manifest.value_keys
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn} do
      sensor_type = insert(:sensor_type)

      data = %{
        name: sensor_type.name,
        make: sensor_type.make,
        visualizer: sensor_type.visualizer,
        identifier: sensor_type.identifier,
        value_keys: sensor_type.value_keys
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["has already been taken"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn} do
      conn = post(conn, Routes.sensor_type_path(conn, :create), %{})
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"],
                   "identifier" => ["can't be blank"],
                   "value_keys" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "sensor type update", %{conn: conn} do
      sensor_type = insert(:sensor_type)
      data = Map.put(%{}, :name, "Sensor76")

      conn = put(conn, Routes.sensor_type_path(conn, :update, sensor_type.id), data)
      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      sensor_type = insert(:sensor_type)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Sensor76")
      conn = put(conn, Routes.sensor_type_path(conn, :update, sensor_type.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Big page size", %{conn: conn} do
      insert_list(3, :sensor_type)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_type_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["sensor_types"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :sensor_type)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_type_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["sensor_types"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.sensor_type_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["sensor_types"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd12 3489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_type_path(conn, :index, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "sensor type delete", %{conn: conn} do
      sensor_type = insert(:sensor_type)

      conn = delete(conn, Routes.sensor_type_path(conn, :delete, sensor_type.id), %{})
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      sensor_type = insert(:sensor_type)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.sensor_type_path(conn, :delete, sensor_type.id), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
