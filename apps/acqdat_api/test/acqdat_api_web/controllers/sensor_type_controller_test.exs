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

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end

    test "fails if authorization header not found", context do
      context = Map.put(context, :refresh_token, "avcbd123489u")
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required headers are not unique", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(400)

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

      data = %{
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(400)
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

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      {:ok, sensor_type} = SensorType.create(data)

      data = Map.put(data, :name, "Sensor76")
      conn = put(conn, Routes.sensor_type_path(conn, :update, sensor_type.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end

    test "fails if require headers are missing", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      {:ok, sensor_type} = SensorType.create(data)

      context = Map.put(context, :refresh_token, "avcbd123489u")
      %{refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = Map.put(data, :name, "Sensor76")
      conn = put(conn, Routes.sensor_type_path(conn, :update, sensor_type.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_sensor_type_with_conn

    test "Big page size", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      {:ok, sensor_type1} = SensorType.create(data)

      data = Map.put(data, :name, "Sensor10001")
      data = Map.put(data, :identifier, "Sensor10001")
      {:ok, sensor_type2} = SensorType.create(data)

      data = Map.put(data, :name, "Sensor1002")
      data = Map.put(data, :identifier, "Sensor1002")
      {:ok, sensor_type3} = SensorType.create(data)

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

    test "Pagination", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      {:ok, sensor_type1} = SensorType.create(data)

      data = Map.put(data, :name, "Sensor10001")
      data = Map.put(data, :identifier, "Sensor10001")
      {:ok, sensor_type2} = SensorType.create(data)

      data = Map.put(data, :name, "Sensor1002")
      data = Map.put(data, :identifier, "Sensor1002")
      {:ok, sensor_type3} = SensorType.create(data)

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

      params = Map.put(params, :page_number, 2)

      page2_response = conn |> json_response(200)
      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["sensor_types"]) == 2
    end

    test "fails if require headers are missing", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create), data)
      response = conn |> json_response(200)
      %{"id" => id} = response
      context = Map.put(context, :refresh_token, "avcbd123489u")
      %{refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = Map.put(data, :name, "Sensor76")
      conn = put(conn, Routes.sensor_type_path(conn, :update, id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_sensor_type_with_conn

    test "sensor type delete", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      {:ok, sensor_type} = SensorType.create(data)

      conn = delete(conn, Routes.sensor_type_path(conn, :delete, sensor_type.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "identifier")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "make")
    end

    test "fails if required headers are missing", context do
      %{sensor_type_params: params, conn: conn, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      data = %{
        name: params.name,
        make: params.make,
        visualizer: params.visualizer,
        identifier: params.identifier,
        value_keys: params.value_keys
      }

      {:ok, sensor_type} = SensorType.create(data)

      context = Map.put(context, :refresh_token, "avcbd123489u")
      %{refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      conn = delete(conn, Routes.sensor_type_path(conn, :delete, sensor_type.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
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
