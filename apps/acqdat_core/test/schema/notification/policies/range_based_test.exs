defmodule AcqdatCore.Schema.Notification.RangeBasedTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Schema.Notification.RangeBased

  describe "eligible?/2" do
    test "returns true if value greater than lower limit" do
      preferences = %{"lower_limit" => 10, "upper_limit" => 0.0}
      value = 20

      result = RangeBased.eligible?(preferences, value)
      assert result
    end

    test "returns false if value lower than lower_limit" do
      preferences = %{"lower_limit" => 10, "upper_limit" => 0}
      value = 5

      result = RangeBased.eligible?(preferences, value)
      refute result
    end

    test "returns true if value between upper and lower limit" do
      preferences = %{"lower_limit" => 10, "upper_limit" => 20}
      value = 15

      result = RangeBased.eligible?(preferences, value)
      assert result
    end

    test "returns true if value greater than upper limit" do
      preferences = %{"lower_limit" => 0.0, "upper_limit" => 20}
      value = 25

      result = RangeBased.eligible?(preferences, value)
      assert result
    end
  end
end
