defmodule AcqdatCore.Notification.PolicyMapTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Notification.PolicyMap

  describe "load" do
    test "returns ok tuple module if found" do
      module = "Elixir.AcqdatCore.Schema.Notification.RangeBased"
      {:ok, data} = PolicyMap.dump(module)
      assert {:ok, returned_module} = PolicyMap.load(data)
      assert String.to_existing_atom(module) == returned_module
    end

    test "returns error tuple if module not found" do
      assert {:error, message} = PolicyMap.load(-1)
      assert message == "module not found"
    end
  end

  describe "dump" do
    test "returns ok tuple module if found" do
      module = "Elixir.AcqdatCore.Schema.Notification.RangeBased"
      {:ok, data} = PolicyMap.dump(module)
      assert data == 0
    end

    test "returns error tuple if module not found" do
      module = "Elixir.AcqdatCore.Schema.Notification"
      assert {:error, message} = PolicyMap.dump(module)
      assert message == "module not found"
    end
  end

  describe "policies" do
    test "returns all notification policies" do
      _policy_list = PolicyMap.policies()
    end
  end
end
