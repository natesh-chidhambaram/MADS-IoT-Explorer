defmodule AcqdatCore.Schema.ToolManagement.ToolBoxTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.ToolManagement.ToolBox

  describe "create_changeset/2" do
    test "returns a valid changeset" do
      params = %{name: "ToolBox1", description: "holds rubber tools"}
      %{valid?: validity} = ToolBox.create_changeset(%ToolBox{}, params)
      assert validity
    end

    test "returns invalid changeset if params empty" do
      params = %{}
      %{valid?: validity} = changeset = ToolBox.create_changeset(%ToolBox{}, params)
      refute validity
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    test "does not update uuid on update" do
      tool_box = insert(:tool_box)
      params = %{name: "ToolBoxNew"}
      changeset = ToolBox.update_changeset(tool_box, params)

      assert {:ok, updated_toolbox} = Repo.update(changeset)
      assert updated_toolbox.id == tool_box.id
      assert updated_toolbox.name != tool_box.name
      assert updated_toolbox.uuid == tool_box.uuid
    end
  end
end
