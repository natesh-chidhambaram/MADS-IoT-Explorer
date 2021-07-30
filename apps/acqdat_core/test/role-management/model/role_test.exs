defmodule AcqdatCore.Model.RoleManagement.RoleTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.Role, as: RoleModel
  alias AcqdatCore.Schema.RoleManagement.Role

  describe "get_all" do
    test "returns data" do
      Repo.delete_all(Role)
      role = insert(:role)

      result = RoleModel.get_all()

      assert result != []
    end
  end

  describe "get_all/1" do
    test "returns data" do
      Repo.delete_all(Role)
      role = insert(:role)

      params = %{page_size: 10, page_number: 1}
      result = RoleModel.get_all(params)

      assert result.entries != []
      assert result.total_entries == 1
    end
  end

  describe "get_all/2" do
    test "returns data with preloads" do
      Repo.delete_all(Role)
      role = insert(:role)

      params = %{page_size: 10, page_number: 1}
      result = RoleModel.get_all(params, [])

      assert result.entries != []
      assert result.total_entries == 1
    end
  end

  describe "update/2" do
    test "updates for valid params" do
      Repo.delete_all(Role)
      role = insert(:role)

      params = %{name: "member"}
      assert {:ok, _} = RoleModel.update(role, params)

      result = hd(RoleModel.get_all())
      assert result.name == "member"
    end

    test "fails for bad role" do
      Repo.delete_all(Role)
      role = %Role{
        id: 43,
        name: "Role-2",
        description: "Member of org"
      }

      params = %{name: "member"}
      assert {:error, _} = RoleModel.update(role, params)
    end
  end

  describe "get_role/1" do
    test "returns a particular role" do
      Repo.delete_all(Role)
      role = insert(:role)

      result = RoleModel.get_role(role.name)
      assert result == role
    end

    test "returns error not found, if not present" do
      result = RoleModel.get_role("BadName")
      assert result == nil
    end
  end

  describe "get_role_id/1" do
    test "returns a particular record" do
      Repo.delete_all(Role)
      role = insert(:role)

      result = RoleModel.get_role_id(role.name)
      assert result == role.id
    end

    test "returns error not found, if not present" do
      result = RoleModel.get_role_id("BadName")
      assert result == nil
    end
  end
end
