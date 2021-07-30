defmodule AcqdatCore.Model.RoleManagement.GroupPolicyTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.RoleManagement.GroupPolicy
  alias AcqdatCore.Model.RoleManagement.GroupPolicy, as: GroupPolicyModel

  def setup_request(_) do
    actions1 = [
      %{"app" => "EntityManagement", "feature" => "Project", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Sensor", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Asset", "action" => "delete"}
    ]

    actions2 = [
      %{"app" => "EntityManagement", "feature" => "AssetType", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Sensor", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Asset", "action" => "delete"}
    ]

    group1 = %{
      name: "group_1",
      actions: actions1
    }

    group2 = %{
      name: "group_2",
      actions: actions2
    }

    [group1: group1, group2: group2]
  end

  describe "remove_policy_from_group/2" do
    setup :setup_request

    test "removes policy for valid input", %{group1: group1} do
      # Testing requires functionality to add group-policy
      assert 0 == 1
    end

    test "returns error not found, if apps are not present", %{group1: group1} do
      assert {0, _} = GroupPolicyModel.remove_policy_from_group(-1, [-1, -2])
    end
  end
end
