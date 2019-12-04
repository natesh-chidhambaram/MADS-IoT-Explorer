defmodule AcqdatApiWeb.Validators.ToolManagement.Employee do
  @moduledoc """
  Exposes validator functions to validate params for Employee related APIs.
  """
  use Params

  defparams(
    verify_employee_params(%{
      name!: :string,
      phone_number!: :string,
      role!: :string,
      address: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
