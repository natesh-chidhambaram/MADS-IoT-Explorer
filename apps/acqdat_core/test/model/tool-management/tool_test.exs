defmodule AcqdatCore.Model.ToolManagament.ToolTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.ToolManagement.Tool
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.ToolManagement.ToolIssue

  describe "create/1" do
  end

  describe "update/2" do
  end

  describe "get/1" do
  end

  describe "get_all" do
  end

  describe "get_all_by_uuids/1" do
    setup do
      tool_box = insert(:tool_box)

      [tool_box: tool_box]
    end

    setup :tool_list

    @tag tool_count: 3
    test "returns a list of tool ids", context do
      %{tools: tools} = context
      tool_uuids = Enum.map(tools, fn tool -> tool.uuid end)

      tool_ids = Tool.get_all_by_uuids_and_status(tool_uuids, "in_inventory")
      assert length(tool_ids) == length(tool_uuids)
    end

    @tag tool_count: 3
    test "returns [] if no uuid match" do
      tool_ids = Tool.get_all_by_uuids_and_status(["1234", "abcd"], "in_inventory")
      assert tool_ids == []
    end
  end

  describe "get_tool_latest_issue_id/1" do
    setup do
      employee = insert(:employee)
      tool_box = insert(:tool_box)
      tool = insert(:tool, tool_box: tool_box)

      [employee: employee, tool_box: tool_box, tool: tool]
    end

    test "returns the latest issue id", context do
      %{employee: employee, tool_box: tool_box, tool: tool} = context

      # making 3 tool issues
      tool_issue(tool, employee, tool_box, Timex.shift(DateTime.utc_now(), minutes: 1))
      tool_issue(tool, employee, tool_box, Timex.shift(DateTime.utc_now(), minutes: 3))
      issue = tool_issue(tool, employee, tool_box, Timex.shift(DateTime.utc_now(), minutes: 5))

      # result is equal to latest added one
      result = Tool.get_tool_latest_issue_id(tool.id)
      assert result == issue.id
    end
  end

  defp tool_issue(tool, employee, tool_box, timestamp) do
    params = %{
      issue_time: timestamp,
      employee_id: employee.id,
      tool_id: tool.id,
      tool_box_id: tool_box.id
    }

    changeset = ToolIssue.changeset(%ToolIssue{}, params)
    {:ok, data} = Repo.insert(changeset)
    data
  end
end
