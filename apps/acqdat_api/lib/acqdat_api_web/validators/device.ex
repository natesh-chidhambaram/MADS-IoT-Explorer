defmodule AcqdatApiWeb.Validators.Device do
  use Params

  defparams(
    verify_device_params(%{
      name!: :string,
      access_token!: :string,
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