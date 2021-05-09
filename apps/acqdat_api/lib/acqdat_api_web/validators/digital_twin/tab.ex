defmodule AcqdatApiWeb.Validators.DigitalTwin.Tab do
  use Params

  defparams(
    verify_tab_params(%{
      name!: :string,
      org_id!: :integer,
      digital_twin_id!: :integer,
      description: :string,
      image_url: :string,
      image_settings: :map
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      digital_twin_id!: :integer
    })
  )
end
