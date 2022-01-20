defmodule AcqdatApiWeb.DashboardManagement.WidgetInstanceControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      widget_instance = insert(:widget_instance)

      [org: org, widget_instance: widget_instance]
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      org: org,
      widget_instance: widget_instance
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.show_widget_instances_path(
            conn,
            :show,
            org.id,
            widget_instance.panel_id,
            widget_instance.widget_id,
            3
          )
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "widget_instance with invalid widget_instance id", %{
      conn: conn,
      org: org,
      widget_instance: widget_instance
    } do
      params = %{
        id: -1
      }

      conn =
        get(
          conn,
          Routes.show_widget_instances_path(
            conn,
            :show,
            org.id,
            widget_instance.panel_id,
            widget_instance.widget_id,
            params.id
          )
        )

      result = conn |> json_response(400)

      assert result == %{
               "detail" => "Widget Instance with this ID does not exists",
               "source" => nil,
               "status_code" => 400,
               "title" => "Invalid entity ID"
             }
    end

    test "widget_instance with valid id", %{
      conn: conn,
      org: org,
      widget_instance: widget_instance
    } do
      conn =
        get(
          conn,
          Routes.show_widget_instances_path(
            conn,
            :show,
            org.id,
            widget_instance.panel_id,
            widget_instance.widget_id,
            widget_instance.id
          )
        )

      result = conn |> json_response(200)

      refute is_nil(result)

      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "label")
    end
  end

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      panel = insert(:panel)
      widget = insert(:widget)

      [org: org, panel: panel, widget: widget]
    end

    test "widget_instance create successfully", %{
      conn: conn,
      org: org,
      panel: panel,
      widget: widget
    } do
      widget_instance_manifest = build(:widget_instance)

      data = %{
        label: widget_instance_manifest.label
      }

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "label")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response["panel"]["widget_layouts"], "#{response["id"]}")

      widget_dimension = response["panel"]["widget_layouts"]["#{response["id"]}"]
      assert widget_dimension["h"] == 20
      assert widget_dimension["w"] == 25
      assert widget_dimension["x"] == 0
      assert widget_dimension["y"] == 0
      assert widget_dimension["type"] == "highcharts"
    end

    test "dynamic card type widget_instance create successfully", %{
      conn: conn,
      org: org,
      panel: panel
    } do
      widget = insert(:widget, category: ["card", "dynamic_card"])
      widget_instance_manifest = build(:widget_instance)

      data = %{
        label: widget_instance_manifest.label
      }

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "label")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response["panel"]["widget_layouts"], "#{response["id"]}")

      widget_dimension = response["panel"]["widget_layouts"]["#{response["id"]}"]
      assert widget_dimension["h"] == 20
      assert widget_dimension["w"] == 15
      assert widget_dimension["x"] == 0
      assert widget_dimension["y"] == 0
      assert widget_dimension["type"] == "dynamic_card"
    end

    test "static card type widget_instance create successfully", %{
      conn: conn,
      org: org,
      panel: panel
    } do
      widget = insert(:widget, category: ["card", "static_card"])
      widget_instance_manifest = build(:widget_instance)

      data = %{
        label: widget_instance_manifest.label
      }

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "label")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response["panel"]["widget_layouts"], "#{response["id"]}")

      widget_dimension = response["panel"]["widget_layouts"]["#{response["id"]}"]
      assert widget_dimension["h"] == 10
      assert widget_dimension["w"] == 15
      assert widget_dimension["x"] == 0
      assert widget_dimension["y"] == 0
      assert widget_dimension["type"] == "static_card"
    end

    test "image card type widget_instance create successfully", %{
      conn: conn,
      org: org,
      panel: panel
    } do
      widget = insert(:widget, category: ["card", "image_card"])
      widget_instance_manifest = build(:widget_instance)

      data = %{
        label: widget_instance_manifest.label
      }

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "label")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response["panel"]["widget_layouts"], "#{response["id"]}")

      widget_dimension = response["panel"]["widget_layouts"]["#{response["id"]}"]
      assert widget_dimension["h"] == 20
      assert widget_dimension["w"] == 15
      assert widget_dimension["x"] == 0
      assert widget_dimension["y"] == 0
      assert widget_dimension["type"] == "image_card"
    end

    test "two widget_instances on same panel", %{
      conn: conn,
      org: org,
      panel: panel,
      widget: widget
    } do
      widget_instance_manifest1 = build(:widget_instance)
      widget_instance_manifest2 = build(:widget_instance)

      data = %{
        label: widget_instance_manifest1.label
      }

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      data = %{
        label: widget_instance_manifest2.label
      }

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "label")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response["panel"]["widget_layouts"], "#{response["id"]}")

      widget_dimension = response["panel"]["widget_layouts"]["#{response["id"]}"]
      assert widget_dimension["h"] == 20
      assert widget_dimension["w"] == 25
      assert widget_dimension["x"] == 0
      assert widget_dimension["y"] == 4
      assert widget_dimension["type"] == "highcharts"
    end

    test "widget_instance duplicate label", %{
      conn: conn,
      org: org,
      panel: panel,
      widget: widget
    } do
      widget_instance_manifest = build(:widget_instance)

      data = %{
        label: widget_instance_manifest.label
      }

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"label" => ["unique widget label under dashboard's panel"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.create_widget_instances_path(conn, :create, 1, 1, 1), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if required params are missing", %{
      conn: conn,
      org: org,
      panel: panel,
      widget: widget
    } do
      data = %{}

      conn =
        post(
          conn,
          Routes.create_widget_instances_path(conn, :create, org.id, panel.id, widget.id),
          data
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"label" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end

  describe "duplicate_widgets/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      widget_instance = insert(:widget_instance)
      [org: org, widget_instance: widget_instance]
    end

    test "duplicate widget_instance", %{
      conn: conn,
      org: org,
      widget_instance: widget_instance
    } do
      data = %{
        widget_id: widget_instance.id,
        label: "testLabel"
      }

      conn =
        post(
          conn,
          Routes.widget_instance_path(conn, :duplicate_widgets, org.id, widget_instance.panel_id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "label")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response["panel"]["widget_layouts"], "#{response["id"]}")

      widget_dimension = response["panel"]["widget_layouts"]["#{response["id"]}"]
      assert widget_dimension["h"] == 20
      assert widget_dimension["w"] == 25
      assert widget_dimension["x"] == 0
      assert widget_dimension["y"] == 0
      assert widget_dimension["type"] == "highcharts"
    end

    test "widget_instance duplicate label", %{
      conn: conn,
      org: org,
      widget_instance: widget_instance
    } do
      data = %{
        widget_id: widget_instance.id,
        label: "testLabel1"
      }

      conn =
        post(
          conn,
          Routes.widget_instance_path(conn, :duplicate_widgets, org.id, widget_instance.panel_id),
          data
        )

      conn =
        post(
          conn,
          Routes.widget_instance_path(conn, :duplicate_widgets, org.id, widget_instance.panel_id),
          data
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"label" => ["unique widget label under dashboard's panel"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.widget_instance_path(conn, :duplicate_widgets, 1, 1), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if required params are missing", %{
      conn: conn,
      org: org,
      widget_instance: widget_instance
    } do
      data = %{}

      conn =
        post(
          conn,
          Routes.widget_instance_path(conn, :duplicate_widgets, org.id, widget_instance.panel_id),
          data
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"label" => ["can't be blank"], "widget_id" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end
end
