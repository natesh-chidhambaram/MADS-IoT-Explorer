defmodule AcqdatCore.Model.RoleManagement.GroupUserTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.RoleManagement.GroupUser
  alias AcqdatCore.Model.RoleManagement.GroupUser, as: GroupUserModel
  alias AcqdatCore.Model.RoleManagement.UserGroup, as: UserGroupModel

  describe "create/1" do
    test "adds Group-User for valid params" do
      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group_id = user_group.id

      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group_id})
      result = Repo.all(GroupUser)

      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}
    end

    test "returns error if params invalid" do
      params = %{}
      assert {:error, _} = GroupUserModel.create(params)
      result = Repo.all(GroupUser)
      assert result == []
    end
  end

  describe "return_groups/1" do
    test "returns groups for valid user" do
      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      {:ok, user_group2} = UserGroupModel.create(%{name: "Group2", org_id: org_id, user_ids: [], policy_ids: []})
      user_group2_id = user_group2.id

      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group1_id})
      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group2_id})
      result = Repo.all(GroupUser)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      [group1, group2] = GroupUserModel.return_groups(user)
      assert group1.user_group_id == user_group1_id
      assert group2.user_group_id == user_group2_id
    end
  end

  describe "update/2" do

    test "succeeds with addition" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)

      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      {:ok, user_group2} = UserGroupModel.create(%{name: "Group2", org_id: org_id, user_ids: [], policy_ids: []})
      user_group2_id = user_group2.id

      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group1_id})
      result = Repo.all(GroupUser)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      GroupUserModel.update(user, [user_group1_id, user_group2_id])

      [group1, group2] = GroupUserModel.return_groups(user)
      assert group1.user_group_id == user_group1_id
      assert group2.user_group_id == user_group2_id
    end

    test "succeeds with deletion" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)

      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      {:ok, user_group2} = UserGroupModel.create(%{name: "Group2", org_id: org_id, user_ids: [], policy_ids: []})
      user_group2_id = user_group2.id

      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group1_id})
      result = Repo.all(GroupUser)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      GroupUserModel.update(user, [])

      assert GroupUserModel.return_groups(user) == []
    end

    test "succeeds with addition and deletion" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)

      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      {:ok, user_group2} = UserGroupModel.create(%{name: "Group2", org_id: org_id, user_ids: [], policy_ids: []})
      user_group2_id = user_group2.id

      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group1_id})
      result = Repo.all(GroupUser)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      GroupUserModel.update(user, [user_group2_id])

      result = GroupUserModel.return_groups(user)
      assert length(result) == 1
      group2 = hd(result)
      assert group2.user_group_id == user_group2_id
    end
  end

  describe "add_user_to_group/2" do
    test "adds Group-User for valid params" do
      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      {:ok, user_group2} = UserGroupModel.create(%{name: "Group2", org_id: org_id, user_ids: [], policy_ids: []})
      user_group2_id = user_group2.id

      GroupUserModel.add_user_to_group(user, [user_group1_id, user_group2_id])

      [group1, group2] = GroupUserModel.return_groups(user)
      assert group1.user_group_id == user_group1_id
      assert group2.user_group_id == user_group2_id
    end

    test "returns user with prefetched values for empty group parameter" do
      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group1_id})

      {:ok, fetched_user} = GroupUserModel.add_user_to_group(user, [])
      assert hd(fetched_user.user_group).user_group_id == user_group1_id
    end

    test "returns error if params invalid" do
      user = insert(:user)
      user_id = user.id

      assert {:error, _} = GroupUserModel.add_user_to_group(user, [-1])
    end
  end

  describe "remove_user_from_group/2" do
    test "removes Group-User for valid params" do
      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      {:ok, user_group2} = UserGroupModel.create(%{name: "Group2", org_id: org_id, user_ids: [], policy_ids: []})
      user_group2_id = user_group2.id
      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group1_id})
      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group2_id})

      GroupUserModel.remove_user_from_group(user, [user_group1_id, user_group2_id])

      assert GroupUserModel.return_groups(user) == []
    end

    test "returns user with prefetched values for empty group parameter" do
      user = insert(:user)
      user_id = user.id
      org = insert(:organisation)
      org_id = org.id
      {:ok, user_group1} = UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})
      user_group1_id = user_group1.id
      GroupUserModel.create(%{user_id: user_id, user_group_id: user_group1_id})

      {:ok, fetched_user} = GroupUserModel.remove_user_from_group(user, [])
      assert hd(fetched_user.user_group).user_group_id == user_group1_id
    end

    test "returns error if params invalid" do
      user = insert(:user)
      user_id = user.id

      assert {:error, _} = GroupUserModel.remove_user_from_group(user, [-1])
    end
  end
end
