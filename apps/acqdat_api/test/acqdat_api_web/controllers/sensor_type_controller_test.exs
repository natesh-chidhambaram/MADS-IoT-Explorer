defmodule AcqdatApiWeb.SensorTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.SensorType
  alias AcqdatCore.Model.User
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_sensor_type_with_conn
    
    test "sensor type create", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")
      data = %{name: params.name, make: params.make, visualizer: params.visualizer, identifier: params.identifier, value_keys: params.value_keys}
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end

    test "fails if authorization header not found", context do
      context = Map.put(context,:refresh_token, "avcbd123489u")
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")
      data = %{name: params.name, make: params.make, visualizer: params.visualizer, identifier: params.identifier, value_keys: params.value_keys}
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required headers are not unique", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")
      data = %{name: params.name, make: params.make, visualizer: params.visualizer, identifier: params.identifier, value_keys: params.value_keys}
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response  = conn |> json_response(400)
      assert response == %{
        "errors" => %{
          "message" => %{"error" => %{"name" => ["has already been taken"]}}
        }
      }
    end

    test "fails if require headers are missing", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")
      data = %{make: params.make, visualizer: params.visualizer, identifier: params.identifier, value_keys: params.value_keys}
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response  = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"name" => ["can't be blank"]}}}
    end
  end

  describe "update/2" do
    setup :setup_sensor_type_with_conn

    test "sensor type update", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")
      data = %{name: params.name, make: params.make, visualizer: params.visualizer, identifier: params.identifier, value_keys: params.value_keys}
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(200)
      %{ "id" => id} = response
      data = Map.put(data, :name, "Sensor76")
      conn = put(conn, Routes.sensor_type_path(conn, :update, id), data)
      response  = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end
  end

  describe "delete/2" do
    setup :setup_sensor_type_with_conn

    test "sensor type delete", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context
      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")
      data = %{name: params.name, make: params.make, visualizer: params.visualizer, identifier: params.identifier, value_keys: params.value_keys}
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(200)
      %{ "id" => id} = response
      conn = delete(conn, Routes.sensor_type_path(conn, :delete, id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end
  end

  def setup_sensor_type_with_conn(_context) do
    sign_up_params = 
        build(:user)
        |> Map.put(:email, "ayoushchourasia@gmail.com")
        |> Map.put(:password, "Qwerty123@")
        |> Map.put(:password_confirmation, "Qwerty123@")
        |> Map.from_struct()

    {:ok, user} = User.create(sign_up_params)  
     
    sign_in_data = %{email: "ayoushchourasia@gmail.com", password: "Qwerty123@"}
    conn = post(conn, Routes.auth_path(conn, :sign_in), sign_in_data)
    result = conn |> json_response(200)
    refresh_token = result["refresh_token"]
    
    params = 
      build(:sensor_type)
      |> Map.put(:name, "Sensor#{Enum.random(0..100)}")
      |> Map.put(:make, "Hitachi")
      |> Map.put(:visualizer, "Chart")
      |> Map.put(:identifier, "MP09SX2218")
      |> Map.put(:value_keys, ["gx", "gy", "gz"])
      |> Map.from_struct()

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")

    [sensor_type_params: params, conn: conn, refresh_token: refresh_token]  
  end
end