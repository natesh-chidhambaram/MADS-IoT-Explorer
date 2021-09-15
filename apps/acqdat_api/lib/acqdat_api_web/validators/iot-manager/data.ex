defmodule AcqdatApiWeb.Validators.IotManager.Data do
  use Params

  defparams(
    verify_gateway_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      project_id!: :integer,
      gateway_id!: :integer
    })
  )

end
