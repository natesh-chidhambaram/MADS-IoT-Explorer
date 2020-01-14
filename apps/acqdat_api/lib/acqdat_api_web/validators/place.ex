defmodule AcqdatApiWeb.Validators.Place do
  use Params

  defparams(
    verify_place_params(%{
      search_string!: :string
    })
  )
end
