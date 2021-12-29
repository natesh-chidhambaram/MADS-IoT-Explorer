defmodule AcqdatApiWeb.Metrics.ReportsErrorHelperTest do
  use ExUnit.Case, async: true

  alias AcqdatApiWeb.Metrics.ReportsErrorHelper

  describe "report error " do
    test "when resource_not_found" do
      error_map = ReportsErrorHelper.error_message(:resource_not_found)

      assert "Invalid resource ID" == error_map.title
      assert "Resource with this ID doesn't exists" == error_map.error
    end

    test "when unauthorized" do
      error_map = ReportsErrorHelper.error_message(:unauthorized)

      assert "Unauthorized Access" == error_map.title
      assert "You are not allowed to perform this action" == error_map.error
    end

    test "when gen_report_error" do
      error_map = ReportsErrorHelper.error_message(:gen_report_error, "Missing data")

      assert "Error while generating report" == error_map.title
      assert "Missing data" == error_map.error
    end

    test "when malformed_data" do
      error_map = ReportsErrorHelper.error_message(:malformed_data, "Invalid request payload")

      assert "Request malformed" == error_map.title
      assert "Invalid request payload" == error_map.error
    end
  end
end
