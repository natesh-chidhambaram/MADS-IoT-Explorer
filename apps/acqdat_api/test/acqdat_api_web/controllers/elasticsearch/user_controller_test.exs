defmodule AcqdatApiWeb.ElasticSearch.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.User
  import AcqdatCore.Support.Factory

  describe "search_users/2" do
    setup :setup_conn

    setup do
      user = insert(:user)
      User.create_index()
      User.seed_user(user)
      :timer.sleep(5000)

      on_exit(fn ->
        User.delete_index()
      end)

      [new_user: user]
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      org = insert(:organisation)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.user_path(conn, :search_users, org.id), %{
          "label" => "Chandu"
        })

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "search with valid params", %{conn: conn, new_user: user} do
      conn =
        get(conn, Routes.user_path(conn, :search_users, user.org_id), %{
          "label" => user.user_credentials.first_name
        })

      result = conn |> json_response(200)

      role = %{
        "description" => user.role.description,
        "id" => user.role.id,
        "name" => user.role.name
      }

      organisation = %{
        "id" => user.org.id,
        "name" => user.org.name,
        "type" => "Organisation",
        "uuid" => user.org.uuid,
        "description" => user.org.description,
        "url" => nil,
        "avatar" => nil
      }

      assert result == %{
               "users" => [
                 %{
                   "email" => user.user_credentials.email,
                   "first_name" => user.user_credentials.first_name,
                   "id" => user.id,
                   "last_name" => user.user_credentials.last_name,
                   "role_id" => user.role_id,
                   "org" => organisation,
                   "role" => role,
                   "is_invited" => false,
                   "phone_number" => nil,
                   "policies" => [],
                   "user_group" => []
                 }
               ],
               "total_entries" => 1
             }
    end

    test "search with no hits in a particular organisation", %{conn: conn, user: user} do
      org = insert(:organisation)

      conn =
        get(conn, Routes.user_path(conn, :search_users, org.id), %{
          "label" => user.user_credentials.first_name
        })

      result = conn |> json_response(200)

      assert result == %{
               "users" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      User.create_index()
      :timer.sleep(5000)
      [user1, user2, user3] = User.seed_multiple_user(org, 3)
      :timer.sleep(5000)
      User.seed_user(user1)
      :timer.sleep(5000)
      User.seed_user(user2)
      :timer.sleep(5000)
      User.seed_user(user3)
      :timer.sleep(5000)

      on_exit(fn ->
        User.delete_index()
      end)

      [user1: user1, user2: user2, user3: user3, new_org: org]
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.user_path(conn, :index, org.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "index with valid params and multiple entries", %{
      conn: conn,
      user1: user1,
      user2: user2,
      user3: user3
    } do
      conn =
        get(conn, Routes.user_path(conn, :index, user1.org_id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"users" => users} = conn |> json_response(200)

      assert length(users) == 3
      [ruser1, ruser2, ruser3] = users
      assert ruser1["email"] == user1.user_credentials.email
      assert ruser1["first_name"] == user1.user_credentials.first_name
      assert ruser1["id"] == user1.id
      assert ruser2["email"] == user2.user_credentials.email
      assert ruser2["first_name"] == user2.user_credentials.first_name
      assert ruser2["id"] == user2.id
      assert ruser3["email"] == user3.user_credentials.email
      assert ruser3["first_name"] == user3.user_credentials.first_name
      assert ruser3["id"] == user3.id
    end
  end
end
