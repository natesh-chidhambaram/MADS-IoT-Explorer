defmodule AcqdatApiWeb.Validators.ApiAccess.Group do
  use Params

  defparams(
    verify_group(%{
      org_id!: :integer,
      user_ids!: {:array, :integer},
      policy_ids!: {:array, :integer}
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer
    })
  )
end
