defmodule AcqdatApiWeb.UserWidgetControllerTest do
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

    test "user widget create", context do
      %{org: org, user: user, conn: conn} = context
      widget = insert(:widget)

      params = %{
        user_id: user.id,
        widget_id: widget.id
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, params), %{})
      response = conn |> json_response(200)

      assert response == %{
               "error" => false,
               "message:" => "Widget Added Successfully",
               "success" => true
             }
    end

    test "fails if authorization header not found", context do
      %{org: org, conn: conn} = context
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, %{}), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", context do
      %{org: org, user: user, conn: conn} = context
      widget = insert(:widget)

      params = %{
        user_id: user.id,
        widget_id: widget.id
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, params), %{})

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, params), %{})
      response = conn |> json_response(400)

      assert response == %{
               "error" => true,
               "message:" => "Widget could not be Added",
               "success" => false
             }
    end

    test "fails if required resource are missing", context do
      %{org: org, user: user, conn: conn} = context

      params = %{
        user_id: user.id,
        widget_id: 2
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, params), %{})

      response = conn |> json_response(404)
      assert response == %{"errors" => %{"message" => "Resource Not Found"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      user = insert(:user)
      [org: org, user: user]
    end

    test "User Widget Data", context do
      %{org: org, user: user, conn: conn} = context
      widget = insert(:widget)

      params = %{
        user_id: user.id,
        widget_id: widget.id
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, params), %{})

      params = %{
        "user_id" => user.id,
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.user_widgets_path(conn, :index, org.id, params))
      response = conn |> json_response(200)
      assert length(response["user_widgets"]) == 1
      assertion_user_widget = List.first(response["user_widgets"])
      assert assertion_user_widget["widget_id"] == widget.id
      assert assertion_user_widget["user_id"] == user.id
      assert assertion_user_widget["widget"]["widget_type_id"] == widget.widget_type_id
    end

    test "fails if invalid token in authorization header", context do
      %{org: org, user: user, conn: conn} = context
      bad_access_token = "qwerty1234567qwerty12"
      user = insert(:user)
      org = insert(:organisation)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "user_id" => user.id,
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.user_widgets_path(conn, :index, org.id, params), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
