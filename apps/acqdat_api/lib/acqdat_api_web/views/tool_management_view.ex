defmodule AcqdatApiWeb.ToolManagementView do
  use AcqdatApiWeb, :view

  @status_verified "verified"
  @status_unidentitified "unidentified"

  def render("employee_verified.json", %{status: :ok, data: employee}) do
    %{
      status: @status_verified,
      employee: %{
        name: employee.name
      }
    }
  end

  def render("tool.json", %{tool: tool}) do
    %{
      tool: %{
        name: tool.name,
        uuid: tool.uuid,
        status: tool.status
      }
    }
  end

  def render("tools.json", %{tools: tools}) do
    %{
      tools: render_many(tools, __MODULE__, "tool.json", as: :tool)
    }
  end

  def render("employee_verified.json", %{status: :error, data: message}) do
    %{
      status: @status_unidentitified,
      message: message
    }
  end

  def render("employee.json", %{employee: employee}) do
    %{
      id: employee.id,
      name: employee.name,
      role: employee.role,
      uuid: employee.uuid,
      phone_number: employee.phone_number
    }
  end

  def render("error.json", %{errors: errors}) do
    %{
      errors: errors
    }
  end

  def render("employees.json", %{employees: employees}) do
    %{
      employees: render_many(employees, __MODULE__, "employee.json", as: :employee)
    }
  end

  def render("transaction_success.json", %{data: data}) do
    %{data: data, status: "success"}
  end

  def render("transaction_error.json", %{errors: errors}) do
    %{errors: errors, status: "error"}
  end
end
