defmodule AcqdatApiWeb.ProcessControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "process create", %{conn: conn} do
      site = insert(:site)

      process = build(:process)

      data = %{
        name: process.name,
        image_url: process.image_url
      }

      params = %{
        site_id: site.id
      }

      conn = post(conn, Routes.process_path(conn, :create, params), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "site_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "image_url")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.process_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", %{conn: conn} do
      process = insert(:process)

      params = %{
        site_id: process.site_id
      }

      conn = post(conn, Routes.process_path(conn, :create, params), %{})

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"]
                 }
               }
             }
    end

    test "process created without image url", %{conn: conn} do
      process = build(:process)
      site = insert(:site)

      params = %{
        site_id: site.id
      }

      data = %{
        name: process.name
      }

      conn = post(conn, Routes.process_path(conn, :create, params), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "site_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "image_url")
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "process update", %{conn: conn} do
      process = insert(:process)
      data = Map.put(%{}, :name, "Water Plant")

      conn = put(conn, Routes.process_path(conn, :update, process.id), data)
      response = conn |> json_response(200)

      assert Map.has_key?(response, "site_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "image_url")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty12345678qwer"
      process = insert(:process)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Plant")
      conn = put(conn, Routes.process_path(conn, :update, process.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "process delete", %{conn: conn} do
      process = insert(:process)

      conn = delete(conn, Routes.process_path(conn, :delete, process.id), %{})
      response = conn |> json_response(200)
      assert Map.has_key?(response, "site_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      process = insert(:process)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.process_path(conn, :delete, process.id), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Process Data", %{conn: conn} do
      process = insert(:process)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.process_path(conn, :index, params))
      response = conn |> json_response(200)
      assert length(response["process"]) == 1
      assertion_process = List.first(response["process"])
      assert assertion_process["id"] == process.id
      assert assertion_process["name"] == process.name
      assert assertion_process["image_url"] == process.image_url
      assert assertion_process["site"]["id"] == process.site.id
      assert assertion_process["site"]["name"] == process.site.name
    end

    test "if params are missing", %{conn: conn} do
      insert_list(3, :process)
      conn = get(conn, Routes.process_path(conn, :index, %{}))
      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["process"]) == response["total_entries"]
    end

    test "Big page size", %{conn: conn} do
      insert_list(3, :process)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.process_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["process"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :process)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.process_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["process"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.process_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["process"]) == 1
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

      conn = get(conn, Routes.process_path(conn, :index, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
