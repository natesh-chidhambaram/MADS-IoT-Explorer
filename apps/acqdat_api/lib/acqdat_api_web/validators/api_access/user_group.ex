defmodule AcqdatApiWeb.Validators.ApiAccess.UserGroup do
  use Params

  defparams(
    verify_group(%{
      name!: :string,
      org_id!: :integer,
      actions!: {:array, :map}
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
