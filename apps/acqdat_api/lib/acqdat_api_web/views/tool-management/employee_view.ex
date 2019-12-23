defmodule AcqdatApiWeb.ToolManagement.EmployeeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ToolManagement.EmployeeView

  def render("employee.json", %{employee: employee}) do
    %{
      employee_id: employee.id,
      address: employee.address,
      name: employee.name,
      phone_number: employee.phone_number,
      role: employee.role,
      uuid: employee.uuid
    }
  end

  def render("index.json", employee) do
    %{
      employee: render_many(employee.entries, EmployeeView, "employee.json"),
      page_number: employee.page_number,
      page_size: employee.page_size,
      total_entries: employee.total_entries,
      total_pages: employee.total_pages
    }
  end
end
