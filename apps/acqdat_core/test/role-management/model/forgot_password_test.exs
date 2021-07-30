defmodule AcqdatCore.Model.RoleManagement.ForgotPasswordTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.RoleManagement.ForgotPassword
  alias AcqdatCore.Model.RoleManagement.UserCredentials
  alias AcqdatApiWeb.Guardian
  alias AcqdatCore.Model.RoleManagement.ForgotPassword, as: ForgotPasswordModel

  describe "create/1" do
    test "adds password for valid params" do
      user = insert(:user)
      user_id = user.id

      {:ok, token, _} =
        Guardian.encode_and_sign(user, %{}, token_type: :access, ttl: {24, :hours})

      params = %{user_id: user_id, token: token}
      ForgotPasswordModel.create(params)
      result = Repo.all(ForgotPassword)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}
    end

    test "returns error if params invalid" do
      params = %{}
      assert {:error, _} = ForgotPasswordModel.create(params)
      result = Repo.all(ForgotPassword)
      assert result == []
    end
  end

  describe "verify_token/1" do
    test "returns user credentials for valid params" do
      user = insert(:user)
      user_id = user.id

      {:ok, token, _} =
        Guardian.encode_and_sign(user, %{}, token_type: :access, ttl: {24, :hours})

      params = %{user_id: user_id, token: token}
      {:ok, _} = ForgotPasswordModel.create(params)
      result = Repo.all(ForgotPassword)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      result = ForgotPasswordModel.verify_token(token)
      assert UserCredentials.get(user.user_credentials_id) == result
    end

    test "returns error if params invalid" do
      result = ForgotPasswordModel.verify_token("Bad access token")
      assert result == {:error, "Token is invalid"}
    end
  end

  describe "delete/1" do
    test "deletes password for valid params" do
      user = insert(:user)
      user_id = user.id

      {:ok, token, _} =
        Guardian.encode_and_sign(user, %{}, token_type: :access, ttl: {24, :hours})

      params = %{user_id: user_id, token: token}
      ForgotPasswordModel.create(params)
      result = Repo.all(ForgotPassword)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      ForgotPasswordModel.delete(user_id)
      result = Repo.all(ForgotPassword)
      assert result == []
    end

    test "returns error if params invalid" do
      assert {:error, _} = ForgotPasswordModel.delete(-1)
      result = Repo.all(ForgotPassword)
      assert result == []
    end
  end
end
