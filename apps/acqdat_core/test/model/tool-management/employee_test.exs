defmodule AcqdatCore.Model.ToolManagament.EmployeeTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.ToolManagement.Employee

  describe "create/1" do
    test "creates an employee with supplied params" do
      params = %{name: "IronMan", phone_number: "1234567", role: "employee"}
      assert {:ok, _employee} = Employee.create(params)
    end

    test "fails if existing name and phone number combination used" do
      employee = insert(:employee)
      params = %{name: employee.name, phone_number: employee.phone_number, role: "employee"}
      assert {:error, changeset} = Employee.create(params)
      assert %{name: ["User already exists!"]} == errors_on(changeset)
    end
  end

  describe "get_all/0" do
    setup :employee_list

    @tag employee_count: 2
    test "returns a list of employee" do
      result = Employee.get_all()
      assert length(result) == 2
    end

    @tag employee_count: 0
    test "returns [] if no employees" do
      result = Employee.get_all()
      assert result == []
    end
  end

  describe "get/1" do
    test "returns an employee by id" do
      employee = insert(:employee)
      assert {:ok, _employee} = Employee.get(employee.id)
    end

    test "returns error tuple if employee not found" do
      assert {:error, message} = Employee.get(-1)
      assert message == "not found"
    end
  end

  describe "update/2" do
    setup do
      employee = insert(:employee)
      [employee: employee]
    end

    test "udpates successfully", context do
      %{employee: employee} = context
      params = %{name: "Superman"}
      assert {:ok, updated_employee} = Employee.update(employee, params)
      assert employee.id == updated_employee.id
      assert employee.name != updated_employee.name
    end
  end
end
