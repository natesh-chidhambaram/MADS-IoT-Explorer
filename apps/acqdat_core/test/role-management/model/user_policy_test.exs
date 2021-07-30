defmodule AcqdatCore.Model.RoleManagement.UserPolicyTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.RoleManagement.UserPolicy
  alias AcqdatCore.Model.RoleManagement.UserPolicy, as: UserPolicyModel

  describe "create/1" do
    test "adds UserPolicy for valid params" do
      user = insert(:user)
      user_id = user.id
      policy = insert(:policy)
      policy_id = policy.id
      {:ok, user_policy} = UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id})
      user_policy_id = user_policy.id
      result = Repo.all(UserPolicy)

      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}
      assert Map.fetch(hd(result), :policy_id) == {:ok, policy_id}
    end

    test "returns error if params invalid" do
      params = %{}
      assert {:error, _} = UserPolicyModel.create(params)
      result = Repo.all(UserPolicy)
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
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}

      UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id1})
      result = Repo.all(UserPolicy)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      UserPolicyModel.update(user, [action1, action2])

      [result1, result2] = Repo.all(UserPolicy)
      assert result1.policy_id == policy_id1
      assert result2.policy_id == policy_id2
    end

    test "succeeds with deletion" do
      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}

      UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id1})
      result = Repo.all(UserPolicy)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      UserPolicyModel.update(user, [])

      assert [] == Repo.all(UserPolicy)
    end

    test "succeeds with addition and deletion" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)

      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}

      UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id1})
      result = Repo.all(UserPolicy)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      UserPolicyModel.update(user, [action2])

      [result2] = Repo.all(UserPolicy)
      assert result2.policy_id == policy_id2
    end
  end

  describe "add_policy_to_user/2" do
    test "adds UserPolicy for valid params" do
      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}

      UserPolicyModel.add_policy_to_user(user, [policy_id1, policy_id2])

      [result1, result2] = Repo.all(UserPolicy)
      assert result1.policy_id == policy_id1
      assert result2.policy_id == policy_id2
    end

    test "error for duplicate add" do
      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}
      UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id1})

      assert {:error, _} = UserPolicyModel.add_policy_to_user(user, [policy_id1, policy_id2])
    end

    test "returns user with prefetched values for empty parameter" do
      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}

      {:ok, userpolicy1} = UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id1})
      result = Repo.all(UserPolicy)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      {:ok, preloaded} = UserPolicyModel.add_policy_to_user(user, [])

      assert hd(preloaded.policies).id == userpolicy1.id
    end

    test "returns error if params invalid" do
      user = insert(:user)
      user_id = user.id

      assert {:error, _} = UserPolicyModel.add_policy_to_user(user, [-1])
    end
  end

  describe "remove_policy_for_user/2" do
    test "removes UserPolicy for valid params" do
      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}
      UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id1})

      UserPolicyModel.remove_policy_for_user(user, [policy_id1, policy_id2])

      assert [] == Repo.all(UserPolicy)
    end

    test "returns user with prefetched values for empty parameter" do
      user = insert(:user)
      user_id = user.id
      policy1 = insert(:policy)
      policy_id1 = policy1.id
      action1 = %{"action" => policy1.action, "feature" => policy1.feature, "app" => policy1.app}
      policy2 = insert(:policy)
      policy_id2 = policy2.id
      action2 = %{"action" => policy2.action, "feature" => policy2.feature, "app" => policy2.app}

      {:ok, userpolicy1} = UserPolicyModel.create(%{user_id: user_id, policy_id: policy_id1})
      result = Repo.all(UserPolicy)
      assert Map.fetch(hd(result), :user_id) == {:ok, user_id}

      {:ok, preloaded} = UserPolicyModel.remove_policy_for_user(user, [])

      assert hd(preloaded.policies).id == userpolicy1.id
    end

    test "no change if params invalid" do
      user = insert(:user)
      user_id = user.id

      result1 = Repo.all(UserPolicy)
      UserPolicyModel.remove_policy_for_user(user, [-1])
      result2 = Repo.all(UserPolicy)

      assert result1 == result2
    end
  end
end
