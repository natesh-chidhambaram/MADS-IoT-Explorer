defmodule AcqdatCore.Schema.ToolManagement.ToolTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.ToolManagement.Tool

  setup do
    tool_box = insert(:tool_box)
    tool_type = insert(:tool_type)

    [tool_box: tool_box, tool_type: tool_type]
  end

  describe "create_changeset/2" do
    test "fails for empty params" do
      params = %{}
      %{valid?: validity} = changeset = Tool.create_changeset(%Tool{}, params)
      refute validity

      assert %{
               name: ["can't be blank"],
               tool_box_id: ["can't be blank"],
               tool_type_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "fails for, assoc constraint, if tool box does not exist", context do
      %{tool_type: tool_type} = context
      params = %{name: "Tool_1", status: "issued", tool_box_id: -1, tool_type_id: tool_type.id}
      assert {:error, changeset} = %Tool{} |> Tool.create_changeset(params) |> Repo.insert()
      assert %{tool_box: ["does not exist"]} == errors_on(changeset)
    end

    test "fails for assoc constraint tool type does not exist", context do
      %{tool_box: tool_box} = context
      params = %{name: "Tool_1", status: "issued", tool_box_id: tool_box.id, tool_type_id: -1}
      assert {:error, changeset} = %Tool{} |> Tool.create_changeset(params) |> Repo.insert()
      assert %{tool_type: ["does not exist"]} == errors_on(changeset)
    end

    test "fails if same tool name entered for a tool box", context do
      %{tool_box: tool_box, tool_type: tool_type} = context
      tool = insert(:tool, tool_box: tool_box, tool_type: tool_type)

      params =
        params = %{
          name: tool.name,
          status: "issued",
          tool_box_id: tool_box.id,
          tool_type_id: tool_type.id
        }

      assert {:error, changeset} = %Tool{} |> Tool.create_changeset(params) |> Repo.insert()
      assert %{name: ["Unique tool name per tool box!"]} == errors_on(changeset)
    end

    test "fails if status not in inclusion list", context do
      %{tool_type: tool_type, tool_box: tool_box} = context

      params = %{
        name: "Tool_1",
        status: "xyz",
        tool_box_id: tool_box.id,
        tool_type_id: tool_type.id
      }

      assert changeset = Tool.create_changeset(%Tool{}, params)
      assert %{status: ["is invalid"]} == errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "uuid does not change on update", context do
      %{tool_type: tool_type, tool_box: tool_box} = context
      tool = insert(:tool, tool_box: tool_box, tool_type: tool_type)

      params = %{name: "ToolNew"}
      changeset = Tool.update_changeset(tool, params)
      assert {:ok, updated_tool} = Repo.update(changeset)
      assert updated_tool.id == tool.id
      assert updated_tool.name != tool.name
      assert updated_tool.uuid == tool.uuid
    end
  end
end
