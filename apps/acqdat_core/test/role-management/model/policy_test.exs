defmodule AcqdatCore.Model.RoleManagement.PolicyTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.Policy, as: PolicyModel
  alias AcqdatCore.Schema.RoleManagement.Policy

  def setup_request(_) do
    actions1 = [
      %{"app" => "EntityManagement", "feature" => "Project", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Sensor", "action" => "update"},
      %{"app" => "EntityManagement", "feature" => "Asset", "action" => "delete"}
    ]

    actions2 = [
      %{"app" => "RoleManagement", "feature" => "AssetType"},
      %{"app" => "RoleManagement", "feature" => "Sensor", "action" => "update"},
      %{"app" => "RoleManagement", "feature" => "Asset", "action" => "delete"}
    ]

    [actions1: actions1, actions2: actions2]
  end

  describe "create/1" do
    setup :setup_request

    test "creates policy", %{actions1: actions1, actions2: actions2} do
      Repo.delete_all(Policy)
      result = PolicyModel.create(hd(actions1))
      assert {:ok, policy} = result
    end

    test "returns error for bad parameters", %{actions1: actions1, actions2: actions2} do
      Repo.delete_all(Policy)
      result = PolicyModel.create(hd(actions2))
      assert {:error, _} = result
    end
  end

  describe "extract_policies/1" do
    setup :setup_request

    test "extracts multiple policies", %{actions1: actions1, actions2: actions2} do
      Repo.delete_all(Policy)
      [action1, action2, action3] = actions1
      assert {:ok, pol1} = PolicyModel.create(action1)
      assert {:ok, pol2} = PolicyModel.create(action2)
      assert {:ok, pol3} = PolicyModel.create(action3)
      [res1, res2, res3] = PolicyModel.extract_policies(actions1)
      assert res1 == pol1.id
      assert res2 == pol2.id
      assert res3 == pol3.id
    end

    test "returns empty for empty searches", %{actions1: actions1, actions2: actions2} do
      Repo.delete_all(Policy)
      [action1, action2, action3] = actions1
      assert {:ok, pol1} = PolicyModel.create(action1)
      assert {:ok, pol2} = PolicyModel.create(action2)
      assert {:ok, pol3} = PolicyModel.create(action3)
      [_ | actions2] = actions2
      assert PolicyModel.extract_policies(actions2) == []
    end

    test "handles bad params", %{actions1: actions1, actions2: actions2} do
      Repo.delete_all(Policy)
      [action1, action2, action3] = actions1
      assert {:ok, pol1} = PolicyModel.create(action1)
      assert {:ok, pol2} = PolicyModel.create(action2)
      assert {:ok, pol3} = PolicyModel.create(action3)
      assert {:error, _} = PolicyModel.extract_policies(actions2)
    end
  end
end
