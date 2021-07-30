defmodule AcqdatCore.Model.RoleManagement.UserCredentialsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.UserCredentials, as: UserCredentialsModel
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Schema.RoleManagement.UserCredentials

  describe "create/1" do

    test "creates with supplied params" do

      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, _} = UserCredentialsModel.create(params)
    end

    test "fails if some parameter is not present" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com"
      }

      assert {:error, _} = UserCredentialsModel.create(params)
    end
  end

  describe "update/2" do

    test "updates with supplied params" do

      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      params = %{
        "first_name" => "Prefect",
      }

      assert {:ok, new_cred} = UserCredentialsModel.update(credentials, params)
      assert new_cred.first_name == "Prefect"
    end

    test "fails if credentials not present" do

      credentials = %UserCredentials{
        id: 44,
        first_name: "Ford",
        email: "ford@sirius.com",
        password_hash: "hash490"
      }

      params = %{
        "first_name" => "Prefect",
        "email" => "test90@gmail.com"
      }

      assert {:error, _} = UserCredentialsModel.update(credentials, params)
    end
  end

  describe "update_details/2" do

    test "updates with supplied params" do

      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      params = %{
        "first_name" => "Prefect",
      }

      assert {:ok, new_cred} = UserCredentialsModel.update_details(credentials.id, params)
      assert new_cred.first_name == "Prefect"
    end

    test "fails if credentials not present" do

      credentials = %UserCredentials{
        id: 44,
        first_name: "Ford",
        email: "ford@sirius.com",
        password_hash: "hash490"
      }

      params = %{
        "first_name" => "Prefect",
        "email" => "test90@gmail.com"
      }

      assert {:error, _} = UserCredentialsModel.update_details(credentials.id, params)
    end
  end

  describe "find_or_create/1" do
    test "finds if exists" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      assert {:ok, new_cred} = UserCredentialsModel.find_or_create(%{email: "test90@gmail.com"})
      assert credentials.id == new_cred.id
    end

    test "create if does not exist" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, new_cred} = UserCredentialsModel.find_or_create(params)
    end

    test "raises error if email does not exist" do
      params = %{
        "first_name" => "Ford",
        "password_hash" => "hash490"
      }

      assert {:error, _} = UserCredentialsModel.find_or_create(params)
    end
  end

  describe "reset_password/2" do
    test "succeeds for valid params" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      new_params = %{
        # "password" => "pass1234^^",
        # "password_confirmation" => "pass1234^^",
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, _} = UserCredentialsModel.reset_password(credentials, new_params)
    end

    test "fails for missing params" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490",
        "password" => "pass123456^^"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      new_params = %{
        "password" => "pass1234^^",
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:error, _} = UserCredentialsModel.reset_password(credentials, new_params)
    end

    test "fails for non matching password confirmation" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490",
        "password" => "pass123456^^"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      new_params = %{
        "password" => "pass1234^^",
        "password_confirmation" => "pass12345678^^",
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:error, _} = UserCredentialsModel.reset_password(credentials, new_params)
    end
  end

  describe "get/1" do
    test "returns a particular record by id" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      {:ok, result} = UserCredentialsModel.get(credentials.id)
      assert not is_nil(result)
      assert result.id == credentials.id
    end

    test "returns error not found for id, if not present" do
      assert {:error, "not found"} = UserCredentialsModel.get(-1)
    end

    test "returns a particular record by email" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      result = UserCredentialsModel.get(credentials.email)
      assert not is_nil(result)
      assert result.email == credentials.email
    end

    test "returns error not found for email, if not present" do
      assert is_nil(UserCredentialsModel.get("DummyEmail"))
    end
  end

  describe "get_by_cred_n_org/2" do
    test "returns a particular record by id" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      user = insert(:user)
      assert {:ok, user} = UserModel.update_user(user, %{"user_credentials_id" => credentials.id})

      result = UserCredentialsModel.get_by_cred_n_org(credentials.id, user.org_id)
      assert not is_nil(result)
      assert result.user_credentials.id == credentials.id
      assert result.org_id == user.org_id
    end

    test "returns error not found for id, if not present" do
      result = UserCredentialsModel.get_by_cred_n_org(-1, -1)
      assert result == nil
    end
  end

  describe "get_by_email_n_org/2" do

    test "returns a particular record by email" do
      params = %{
        "first_name" => "Ford",
        "email" => "test90@gmail.com",
        "password_hash" => "hash490"
      }

      assert {:ok, credentials} = UserCredentialsModel.create(params)

      user = insert(:user)
      assert {:ok, user} = UserModel.update_user(user, %{"user_credentials_id" => credentials.id})

      assert user.user_credentials_id == credentials.id

      result = UserCredentialsModel.get_by_email_n_org(credentials.email, user.org_id)
      assert not is_nil(result)
      assert result.user_credentials.email == credentials.email
      assert result.org_id == user.org_id
    end

    test "returns error not found for email, if not present" do
      result = UserCredentialsModel.get_by_email_n_org("dummy_email@email.email", -1)
      assert result == nil
    end
  end
end
