defmodule AcqdatApiWeb.Validators.ToolManagement do
  use Params

  defparams(
    tool_transaction_params(%{
      user_uuid!: :string,
      tool_box_uuid!: :string,
      tool_ids!: [:string],
      transaction: :string
    })
  )

  defparams(
    verify_tool(%{
      tool_box_uuid!: :string,
      tool_uuid!: :string
    })
  )

  defparams(
    verify_employee_status(%{
      employee_uuid!: :string
    })
  )

  defparams(
    verify_tool_box_status(%{
      tool_box_uuid!: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
