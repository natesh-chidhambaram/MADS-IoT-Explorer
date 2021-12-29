defmodule CockpitWeb.AuthControllerTest do
  use ExUnit.Case, async: true
  use CockpitWeb.ConnCase
  use AcqdatCore.DataCase

  setup [:registration_data]

  describe "registration/2" do
    test "Return success when user is registered", %{conn: conn, params: params} do
      resp =
        conn
        |> post(Routes.auth_path(conn, :registration), params)
        |> json_response(200)

      assert resp == %{"status" => "success"}
      refute resp["status"] == :error
    end

    test "Return error when email is already taken", %{conn: conn, params: params} do
      resp =
        conn
        |> post(Routes.auth_path(conn, :registration), params)
        |> json_response(200)

      assert resp == %{"status" => "success"}

      resp2 =
        conn
        |> post(Routes.auth_path(conn, :registration), params)
        |> json_response(400)

      assert resp2 == %{
               "errors" => %{"email" => "has already been taken"},
               "title" => "Invalid request"
             }
    end

    test "Return error when required data is missing from params", %{conn: conn, params: params} do
      # set-up
      params = Map.delete(params, :password)

      resp =
        conn
        |> post(Routes.auth_path(conn, :registration), params)
        |> json_response(400)

      assert resp == %{
               "errors" => %{"password" => "can't be blank"},
               "title" => "Malformed request"
             }
    end

    test "Return error when data is not in correct data type", %{conn: conn, params: params} do
      # set-up
      params = Map.put(params, :first_name, 12345)

      resp =
        conn
        |> post(Routes.auth_path(conn, :registration), params)
        |> json_response(400)

      assert resp == %{
               "errors" => %{"first_name" => "is invalid"},
               "title" => "Malformed request"
             }
    end

    test "Return error when email is not in correct format", %{conn: conn, params: params} do
      # set-up
      params = Map.put(params, :email, "dummy_mail.com")

      resp =
        conn
        |> post(Routes.auth_path(conn, :registration), params)
        |> json_response(400)

      assert resp == %{
               "errors" => %{"email" => "has invalid format"},
               "title" => "Invalid request"
             }
    end
  end

  describe "sign_in/2" do
    test "Return token when user is successfully login", %{conn: conn, params: params} do
      post(conn, Routes.auth_path(conn, :registration), params)

      login_params = %{email: params.email, password: params.password}

      resp =
        conn
        |> post(Routes.auth_path(conn, :sign_in), login_params)
        |> json_response(200)

      refute is_nil(resp)

      assert %{
               "access_token" => _access_token,
               "credentials_id" => _credentials_id,
               "email" => email,
               "refresh_token" => _refresh_token
             } = resp

      assert email == params.email
    end

    test "Return error when invalid email is given", %{conn: conn, params: params} do
      login_params = %{email: params.email, password: params.password}

      resp =
        conn
        |> post(Routes.auth_path(conn, :sign_in), login_params)
        |> json_response(403)

      assert resp == %{
               "errors" => %{"credential" => "Invalid email or password"},
               "title" => "Invalid credentials"
             }
    end

    test "Return error when required data is missing from params", %{conn: conn, params: params} do
      login_params = %{email: params.email}

      resp =
        conn
        |> post(Routes.auth_path(conn, :sign_in), login_params)
        |> json_response(400)

      assert resp == %{
               "errors" => %{"password" => "can't be blank"},
               "title" => "Malformed request"
             }
    end
  end

  # TODO: need to add Mox so that data should not sent over the mail while test
  describe "forgot_password/2" do
    test "Return status sent once email is validated and mail sent", %{conn: conn, params: params} do
      post(conn, Routes.auth_path(conn, :registration), params)

      resp =
        conn
        |> post(Routes.auth_path(conn, :forgot_password), %{email: params.email})
        |> json_response(200)

      assert resp == %{"status" => "mail_sent"}
    end

    test "Return error when invalid email is given", %{conn: conn, params: params} do
      resp =
        conn
        |> post(Routes.auth_path(conn, :forgot_password), %{email: params.email})
        |> json_response(403)

      assert resp == %{
               "errors" => %{"credential" => "not_found"},
               "title" => "Invalid credentials"
             }
    end

    test "Return error when required data is missing from params", %{conn: conn} do
      resp =
        conn
        |> post(Routes.auth_path(conn, :forgot_password), %{})
        |> json_response(400)

      assert resp == %{"errors" => %{"email" => "can't be blank"}, "title" => "Malformed request"}
    end
  end

  defp registration_data(context) do
    params = %{
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      email: Faker.Internet.email(),
      avatar: Faker.Avatar.image_url(),
      password: "Datakrew@123",
      phone_number: Faker.Phone.PtPt.cell_number()
    }

    {:ok, Map.put(context, :params, params)}
  end
end
