defmodule AcqdatApiWeb.DeviceControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.User
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn
    
    test "device create", %{conn: conn} do
      device_manifest = build(:device)
      
      data = %{
        name: device_manifest.name,
        access_token: device_manifest.access_token,
        description: device_manifest.description,
        uuid: device_manifest.uuid        
      }

      conn = post(conn, Routes.device_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "access_token")
      assert Map.has_key?(response, "description")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.device_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn} do
      device = insert(:device)  
      data = %{
        name: device.name,
        access_token: device.access_token,
        description: device.description,
        uuid: device.uuid   
      }

      conn = post(conn, Routes.device_path(conn, :create), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["has already been taken"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn} do
      conn = post(conn, Routes.device_path(conn, :create), %{})
      response = conn |> json_response(400)
      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"],
                   "access_token" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "device update", %{conn: conn} do
      device = insert(:device)
      data = Map.put(%{}, :name, "Water Plant")

      conn = put(conn, Routes.device_path(conn, :update, device.id), data)
      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "access_token")
      assert Map.has_key?(response, "description")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty12345678qwer"
      device = insert(:device)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Plant")
      conn = put(conn, Routes.device_path(conn, :update, device.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Big page size", %{conn: conn} do
      insert_list(3, :device)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.device_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["devices"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :device)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.device_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["devices"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.device_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["devices"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.device_path(conn, :index, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "device delete", %{conn: conn} do
      device = insert(:device)

      conn = delete(conn, Routes.device_path(conn, :delete, device.id), %{})
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "access_token")
      assert Map.has_key?(response, "description")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      device = insert(:device)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.device_path(conn, :delete, device.id), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  def setup_conn(%{conn: conn}) do
    params =
      build(:user)
      |> Map.put(:password, "stark1234")
      |> Map.put(:password_confirmation, "stark1234")
      |> Map.from_struct()

    {:ok, user} = User.create(params)
    sign_in_data = %{email: user.email, password: params.password}
    conn = post(conn, Routes.auth_path(conn, :sign_in), sign_in_data)
    result = conn |> json_response(200)
    access_token = result["access_token"]
    
    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{access_token}")

    [conn: conn]
  end
end