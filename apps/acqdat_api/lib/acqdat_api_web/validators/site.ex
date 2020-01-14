defmodule AcqdatApiWeb.Validators.Site do
  use Params

  defparams(
    verify_site_params(%{
      name!: :string,
      location_details!: :map,
      image_url: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
