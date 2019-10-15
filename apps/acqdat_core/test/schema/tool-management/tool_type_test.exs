defmodule AcqdatCore.Schema.ToolManagement.ToolTypeTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.ToolManagement.ToolType
  alias AcqdatCore.Repo

  describe "changeset/2" do
    test "returns a valid changeset" do
      params = %{identifier: "cutter-tool"}
      %{valid?: validity} = ToolType.changeset(%ToolType{}, params)
      assert validity
    end

    test "returns invalid changeset if params missing" do
      params = %{}
      %{valid?: validity} = changeset = ToolType.changeset(%ToolType{}, params)

      refute validity
      assert %{identifier: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if unique identifier violation" do
      tool_type = insert(:tool_type)
      params = %{identifier: tool_type.identifier}
      changeset = ToolType.changeset(%ToolType{}, params)
      {:error, changeset} = Repo.insert(changeset)
      assert %{identifier: ["Tool type already exists!"]} == errors_on(changeset)
    end
  end
end
