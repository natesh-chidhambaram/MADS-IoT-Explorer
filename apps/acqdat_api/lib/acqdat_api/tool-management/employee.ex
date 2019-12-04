defmodule AcqdatApi.ToolManagement.Employee do
  alias AcqdatCore.Model.ToolManagement.Employee, as: EmployeeModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      name: name,
      phone_number: phone_number,
      role: role,
      address: address
    } = params

    verify_employee(
      EmployeeModel.create(%{
        name: name,
        phone_number: phone_number,
        role: role,
        address: address
      })
    )
  end

  defp verify_employee({:ok, employee}) do
    {:ok,
     %{
       id: employee.id,
       name: employee.name,
       phone_number: employee.phone_number,
       role: employee.role,
       address: employee.address,
       uuid: employee.uuid
     }}
  end

  defp verify_employee({:error, employee}) do
    {:error, %{error: extract_changeset_error(employee)}}
  end
end
