defmodule AcqdatApiWeb.Validators.ToolManagement.ToolType do
  use Params

  defparams(
    verify_tool_type_params(%{
      identifier!: :string,
      description: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
