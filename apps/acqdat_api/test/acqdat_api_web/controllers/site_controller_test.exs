defmodule AcqdatApiWeb.SiteControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "site create", %{conn: conn} do
      site = build(:site)

      data = %{
        name: site.name,
        location_details: site.location_details,
        image_url: site.image_url
      }

      conn = post(conn, Routes.site_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "location_details")
      assert Map.has_key?(response, "image_url")
    end

    test "fails if authorization header is missing", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.site_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn} do
      site = insert(:site)

      data = %{
        name: site.name,
        location_details: site.location_details,
        image_url: site.image_url
      }

      conn = post(conn, Routes.site_path(conn, :create), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["has already been taken"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn} do
      conn = post(conn, Routes.site_path(conn, :create), %{})
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"],
                   "location_details" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "site_update", %{conn: conn} do
      site = insert(:site)
      data = Map.put(%{}, :name, "Site 1")

      conn = put(conn, Routes.site_path(conn, :update, site.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "location_details")
      assert Map.has_key?(response, "image_url")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      site = insert(:site)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Site 1")
      conn = put(conn, Routes.site_path(conn, :update, site.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if wrong site id is given", %{conn: conn} do
      site = insert(:site)

      data = %{name: "Site 2"}
      conn = put(conn, Routes.site_path(conn, :update, site.id + 2), data)
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Big page size", %{conn: conn} do
      insert_list(3, :site)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.site_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["sites"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :site)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.site_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["sites"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.site_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["sites"]) == 1
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

      conn = get(conn, Routes.site_path(conn, :index, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "site delete", %{conn: conn} do
      site = insert(:site)

      conn = delete(conn, Routes.site_path(conn, :delete, site.id), %{})
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "location_details")
      assert Map.has_key?(response, "image_url")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      site = insert(:site)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.site_path(conn, :delete, site.id), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
