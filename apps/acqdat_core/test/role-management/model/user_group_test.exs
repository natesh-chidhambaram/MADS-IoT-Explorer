defmodule AcqdatCore.Model.RoleManagement.UserGroupTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.UserGroup, as: UserGroupModel
  alias AcqdatCore.Schema.RoleManagement.UserGroup

  describe "create/1" do
    test "adds UserGroup for valid params" do
      org = insert(:organisation)
      org_id = org.id

      {:ok, user_group} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      user_group_id = user_group.id
      result = Repo.all(UserGroup)

      assert Map.fetch(hd(result), :name) == {:ok, "Group1"}
      assert Map.fetch(hd(result), :org_id) == {:ok, org_id}
    end

    test "returns error if params invalid" do
      params = %{}
      assert {:error, _} = UserGroupModel.create(params)
      result = Repo.all(UserGroup)
      assert result == []
    end
  end

  describe "update/2" do
    test "succeeds with addition" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)

      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      policy2 = insert(:policy)
      policy_id2 = policy2.id

      org_id = user.org_id

      {:ok, user_group} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      {:ok, result1} =
        UserGroupModel.update(user_group, %{
          user_ids: [user_id],
          policy_ids: [policy_id1, policy_id2]
        })

      [pol1, pol2] = result1.policies
      assert pol1.id == policy_id1
      assert pol2.id == policy_id2
      assert hd(result1.users).id == user_id
    end

    test "succeeds with deletion" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)

      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      policy2 = insert(:policy)
      policy_id2 = policy2.id

      org_id = user.org_id

      {:ok, user_group} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      {:ok, result1} =
        UserGroupModel.update(user_group, %{
          user_ids: [user_id],
          policy_ids: [policy_id1, policy_id2]
        })

      [pol1, pol2] = result1.policies
      assert pol1.id == policy_id1
      assert pol2.id == policy_id2
      assert hd(result1.users).id == user_id

      {:ok, result1} = UserGroupModel.update(user_group, %{user_ids: [], policy_ids: []})
      assert result1.users == []
      assert result1.policies == []
    end

    test "succeeds with addition and deletion" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)

      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      policy2 = insert(:policy)
      policy_id2 = policy2.id

      org_id = user.org_id

      {:ok, user_group} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      {:ok, result1} =
        UserGroupModel.update(user_group, %{user_ids: [user_id], policy_ids: [policy_id1]})

      [pol1] = result1.policies
      assert pol1.id == policy_id1
      assert hd(result1.users).id == user_id

      {:ok, result1} =
        UserGroupModel.update(user_group, %{user_ids: [], policy_ids: [policy_id2]})

      assert hd(result1.policies).id == policy_id2
    end
  end

  describe "normal_update/2" do
    test "updates successfully for good params" do
      user = insert(:user)
      user_id = user.id
      org_id = user.org_id

      {:ok, user_group} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      {:ok, updated} = UserGroupModel.normal_update(user_group, %{name: "UpdatedGrp1"})

      assert updated.name == "UpdatedGrp1"
    end

    test "raises error for bad usergroup" do
      assert {:error, _} =
               UserGroupModel.normal_update(%UserGroup{id: 43, name: "BadGroup", org_id: -1}, %{})
    end
  end

  describe "get/1" do
    test "gets when possible" do
      user = insert(:user)
      user_id = user.id
      org_id = user.org_id

      {:ok, user_group} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      {:ok, result} = UserGroupModel.get(user_group.id)
      assert result.id == user_group.id
    end

    test "error when not possible" do
      assert {:error, _} = UserGroupModel.get(-1)
    end
  end

  describe "extract_groups/1" do
    test "filters invalid groups" do
      org_id = insert(:organisation).id

      {:ok, user_group1} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      {:ok, user_group2} =
        UserGroupModel.create(%{name: "Group2", org_id: org_id, user_ids: [], policy_ids: []})

      {:ok, user_group3} =
        UserGroupModel.create(%{name: "Group3", org_id: org_id, user_ids: [], policy_ids: []})

      assert [user_group1.id, user_group2.id, user_group3.id] ==
               UserGroupModel.extract_groups([
                 user_group1.id,
                 user_group2.id,
                 user_group3.id,
                 43,
                 76
               ])
    end

    test "true purpose of function???" do
      # Remove function if made by mistake, remove this test if intentional
      assert false
    end
  end

  describe "policies/1" do
    test "returns policies of group" do
      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      policy2 = insert(:policy)
      policy_id2 = policy2.id

      org_id = user.org_id

      {:ok, user_group} =
        UserGroupModel.create(%{
          name: "Group1",
          org_id: org_id,
          user_ids: [user_id],
          policy_ids: [policy_id1, policy_id2]
        })

      assert [policy_id1, policy_id2] == UserGroupModel.policies(user_group.id)
    end

    test "empty if bad user_group" do
      assert [] == UserGroupModel.policies(-1)
    end
  end

  describe "get_all/2" do
    test "gets prefetched when possible" do
      user = insert(:user)
      user_id = user.id
      org_id = user.org_id

      {:ok, user_group} =
        UserGroupModel.create(%{name: "Group1", org_id: org_id, user_ids: [], policy_ids: []})

      result =
        hd(
          UserGroupModel.get_all(%{page_size: 10, page_number: 1, org_id: org_id}, [:org]).entries
        )

      assert result.id == user_group.id
      assert result.org.id == org_id
    end

    test "error when not possible" do
      result = UserGroupModel.get_all(%{page_size: 10, page_number: 1, org_id: -1}, [])
      assert result.total_entries == 0
    end
  end

  describe "return_policies/2" do
    test "gets prefetched policies when possible" do
      user = insert(:user)
      user_id = user.id
      org_id = user.org_id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      policy2 = insert(:policy)
      policy_id2 = policy2.id

      {:ok, user_group} =
        UserGroupModel.create(%{
          name: "Group1",
          org_id: org_id,
          user_ids: [],
          policy_ids: [policy_id1, policy_id2]
        })

      result =
        UserGroupModel.return_policies(
          %{page_size: 10, page_number: 1, org_id: org_id, group_ids: [user_group.id]},
          [:org]
        )

      # IO.inspect(result)

      # Does not have anything to do with policies??
      assert false
    end

    test "error when not possible" do
      result =
        UserGroupModel.return_policies(
          %{page_size: 10, page_number: 1, org_id: -1, group_ids: [-1]},
          []
        )

      assert result.total_entries == 0
    end
  end

  describe "delete/1" do
    test "deletes for good input" do
      user = insert(:user)
      user_id = user.id
      org_id = user.org_id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      policy2 = insert(:policy)
      policy_id2 = policy2.id

      {:ok, user_group} =
        UserGroupModel.create(%{
          name: "Group1",
          org_id: org_id,
          user_ids: [],
          policy_ids: [policy_id1, policy_id2]
        })

      {:ok, _} = UserGroupModel.delete(user_group)

      assert [] == Repo.all(UserGroup)
    end

    test "error for bad or outdated input" do
      assert {:error, _} = UserGroupModel.delete(%UserGroup{id: 43, name: "BadGroup", org_id: -1})
    end
  end

  describe "return_multiple_user_groups/1" do
    test "returns prefetched groups" do
      user = insert(:user)
      user_id = user.id
      org_id = user.org_id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      policy2 = insert(:policy)
      policy_id2 = policy2.id

      {:ok, user_group} =
        UserGroupModel.create(%{
          name: "Group1",
          org_id: org_id,
          user_ids: [],
          policy_ids: [policy_id1, policy_id2]
        })

      result = hd(UserGroupModel.return_multiple_user_groups([user_group.id]))

      [pol1, pol2] = result.policies
      assert pol1.id == policy_id1
      assert pol2.id == policy_id2
    end

    test "handles bad input" do
      assert [] == UserGroupModel.return_multiple_user_groups([-1])
    end
  end
end
