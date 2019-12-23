defmodule AcqdatApiWeb.Validators.ToolManagement.ToolBox do
  use Params

  defparams(
    verify_tool_box_params(%{
      name!: :string,
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
