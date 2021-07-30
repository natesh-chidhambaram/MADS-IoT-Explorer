defmodule AcqdatCore.Model.RoleManagement.UserTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Model.RoleManagement.UserGroup, as: UserGroupModel
  alias AcqdatCore.Model.RoleManagement.GroupUser, as: GroupUserModel
  alias AcqdatCore.Model.RoleManagement.UserPolicy, as: UserPolicyModel

  describe "create/1" do
    test "creates with valid params" do

      user_credentials = insert(:user_credentials)
      role = insert(:role)
      org = insert(:organisation)
      params = %{
        "user_credentials_id" => user_credentials.id,
        "is_invited" => false,
        "role_id" => role.id,
        "org_id" => org.id
      }

      {:ok, user} = UserModel.create(params)
      assert user.org_id == org.id
      assert user.role_id == role.id
      assert user.user_credentials_id == user_credentials.id
    end

    test "raises error for missing parameters" do
      user_credentials = insert(:user_credentials)
      role = insert(:role)
      params = %{
        "user_credentials_id" => user_credentials.id,
        "is_invited" => false,
        "role_id" => role.id
      }

      {:error, _} = UserModel.create(params)
    end
  end

  describe "get/1" do

    test "gets by id" do
      user = insert(:user)
      {:ok, new_user} = UserModel.get(user.id)
      assert user.id == new_user.id
    end

    test "raises error for bad id" do
      assert {:error, "not found"} = UserModel.get(-1)
    end

    test "gets by email" do
      user = insert(:user)
      new_user = UserModel.get(user.user_credentials.email)
      assert user.user_credentials.email == new_user.user_credentials.email
    end

    test "raises error for bad email" do
      assert {:error, "not found"} = UserModel.get("bademail")
    end
  end

  describe "get_for_view/1" do
    test "succeeds for multiple ids" do
      user1 = insert(:user)
      user2 = insert(:user)
      user3 = insert(:user)
      user4 = insert(:user)
      [new1, new2, new3, new4] = UserModel.get_for_view([user1.id, user2.id, user4.id, user3.id])
      assert new1.id == user1.id
      assert new2.id == user2.id
      assert new3.id == user3.id
      assert new4.id == user4.id
    end

    test "returns empty for bad params" do
      assert [] == UserModel.get_for_view([-1])
    end
  end

  describe "get_by_email/1" do
    test "gets by email" do
      user = insert(:user)
      {:ok, user_cred} = UserModel.get_by_email(user.user_credentials.email)
      assert user.user_credentials.email == user_cred.email
    end

    test "raises error for bad email" do
      assert {:error, "not found"} = UserModel.get_by_email("bademail")
    end
  end

  describe "get_all/1" do
    test "returns users" do
      insert(:user)
      insert(:user)
      insert(:user)
      insert(:user)
      insert(:user)

      result = UserModel.get_all(%{page_size: 10, page_number: 1})
      assert result.total_entries == 5
    end
  end

  describe "get_all/2" do
    test "returns users" do
      user1 = insert(:user)
      insert(:user)
      insert(:user)
      insert(:user)
      insert(:user)

      result = UserModel.get_all(%{page_size: 10, page_number: 1, org_id: user1.org_id}, [:assets])
      assert result.total_entries == 1
      assert hd(result.entries).id == user1.id
      assert hd(result.entries).assets == []
    end
  end

  describe "load_user" do
    test "returns users by org_id" do
      user_credentials1 = insert(:user_credentials)
      role1 = insert(:role)
      org = insert(:organisation)
      params = %{
        "user_credentials_id" => user_credentials1.id,
        "is_invited" => false,
        "role_id" => role1.id,
        "org_id" => org.id
      }

      {:ok, user1} = UserModel.create(params)

      user_credentials2 = insert(:user_credentials)
      role2 = insert(:role)
      org = insert(:organisation)
      params = %{
        "user_credentials_id" => user_credentials2.id,
        "is_invited" => false,
        "role_id" => role2.id,
        "org_id" => org.id
      }

      {:ok, user2} = UserModel.create(params)

      [res1, res2] = UserModel.load_user(org.id)
      assert res1.id == user1.id
      assert res2.id == user2.id
    end

    test "returns empty for bad org_id" do
      assert [] == UserModel.load_user(-1)
    end
  end

  describe "delete/1" do
    test "deletes valid user" do
      user = insert(:user)
      assert {:ok, _} = UserModel.delete(user)
      {:ok, result} = UserModel.get(user.id)
      assert result.is_deleted == true
    end
    test "raises error for invalid user" do
      assert {:error, _} = UserModel.delete(%User{id: -1})
    end
  end

  describe "update_user/2" do
    test "update succeeds for non-group, non-policy params" do
      user = insert(:user)
      org = insert(:organisation)

      {:ok, updated} = UserModel.update_user(user, %{"org_id" => org.id})

      assert updated.org_id == org.id
    end

    test "update returns error for bad params" do
      user = insert(:user)
      org = insert(:organisation)

      assert {:error, _} = UserModel.update_user(%User{id: 80}, %{"org_id" => org.id})
    end

    test "update succeeds for group and policy params" do
      user = insert(:user)
      policy1 = insert(:policy)
      policy2 = insert(:policy)
      {:ok, group1} = UserGroupModel.create(%{name: "Group1", org_id: user.org_id, user_ids: [], policy_ids: []})
      {:ok, group2} = UserGroupModel.create(%{name: "Group2", org_id: user.org_id, user_ids: [], policy_ids: []})

      GroupUserModel.create(%{user_id: user.id, user_group_id: group1.id})
      UserPolicyModel.create(%{user_id: user.id, policy_id: policy1.id})
      result = UserModel.get_all(%{page_size: 10, page_number: 1, org_id: user.org_id}, [:policies, :user_group])
      assert hd(hd(result.entries).policies).policy_id == policy1.id
      assert hd(hd(result.entries).user_group).user_group_id == group1.id

      UserModel.update_user(user, %{"group_ids" => [group2.id], "policies" => [policy2.id]})

      result = UserModel.get_all(%{page_size: 10, page_number: 1, org_id: user.org_id}, [:policies, :user_group])
      assert hd(hd(result.entries).policies).policy_id == policy2.id
      assert hd(hd(result.entries).user_group).user_group_id == group2.id
    end
  end

  describe "set_invited_to_false/1" do
    test "sets invited to false" do
      user = insert(:user)
      {:ok, user} = UserModel.update_user(user, %{"is_invited" => true})
      assert user.is_invited == true
      {:ok, result} = UserModel.set_invited_to_false(user)
      assert result.is_invited == false
    end
  end

  describe "set_asset/2" do
    test "associates assets with user" do
      user = insert(:user)
      asset = insert(:asset)

      asset_params = [%{"id" => asset.id, "name" => asset.name}]

      {:ok, result} = UserModel.set_asset(user, asset_params)
      assert not is_nil(result)
    end
  end

  describe "set_app/2" do
    test "associates app with user" do
      user = insert(:user)
      app = insert(:app)

      asset_params = [%{"id" => app.id, "name" => app.name}]

      {:ok, result} = UserModel.set_apps(user, asset_params)
      assert not is_nil(result)
    end
  end

  describe "extract_email/1" do
    test "obtains prefetched user" do
      user = insert(:user)
      user_cred = insert(:user_credentials)

      {:ok, user} = UserModel.update_user(user, %{"user_credentials_id" => user_cred.id})
      result = UserModel.extract_email(user.id)
      assert result.user_credentials.email == user_cred.email
    end

    test "raises error for bad user" do
      assert {:error, _} = UserModel.extract_email(-1)
    end
  end

  describe "fetch_user_orgs_by_email/1" do

    test "gets org_id for multiple orgs" do
      user1 = insert(:user)
      org1 = insert(:organisation)
      user2 = insert(:user)
      org2 = insert(:organisation)
      user_cred = insert(:user_credentials)

      {:ok, user1} = UserModel.update_user(user1, %{"user_credentials_id" => user_cred.id, "org_id" => org1.id})
      {:ok, user2} = UserModel.update_user(user2, %{"user_credentials_id" => user_cred.id, "org_id" => org2.id})

      [id1, id2] = UserModel.fetch_user_orgs_by_email(user_cred.email)
      assert id1 == org1.id
      assert id2 == org2.id
    end

    test "returns empty for bed email" do
      assert [] == UserModel.fetch_user_orgs_by_email("BadEmail")
    end
  end

  describe "fetch_user_by_email_n_org/1" do

    test "gets user for valid input" do
      user1 = insert(:user)
      org1 = insert(:organisation)
      user_cred = insert(:user_credentials)

      {:ok, user1} = UserModel.update_user(user1, %{"user_credentials_id" => user_cred.id, "org_id" => org1.id})

      result1 = UserModel.fetch_user_by_email_n_org(user_cred.email, org1.id)
      assert user1.id == result1.id
    end

    test "returns empty for bed email" do
      assert is_nil(UserModel.fetch_user_by_email_n_org("BadEmail", -1))
    end
  end

  describe "verify_email/1" do
    test "returns true for valid email" do
      user1 = insert(:user)
      org1 = insert(:organisation)
      user_cred = insert(:user_credentials)

      {:ok, user1} = UserModel.update_user(user1, %{"user_credentials_id" => user_cred.id, "org_id" => org1.id})

      assert true == UserModel.verify_email(user_cred.email)
    end

    test "returns false for bad email" do
      assert false == UserModel.verify_email("BadEmail")
    end
  end
end
