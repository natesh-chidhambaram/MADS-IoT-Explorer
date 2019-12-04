defmodule AcqdatApiWeb.Validators.ToolManagement.Tool do
  use Params

  defparams(
    verify_tool_params(%{
      name!: :string,
      status: :string,
      description: :string,
      tool_type_id!: :integer,
      tool_box_id!: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
