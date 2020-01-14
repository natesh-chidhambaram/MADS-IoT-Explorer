defmodule AcqdatApiWeb.Validators.DigitalTwin do
  use Params

  defparams(
    verify_digital_twin_params(%{
      name!: :string,
      process_id: :integer,
      site_id: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
