defmodule AcqdatApiWeb.Validators.EntityManagement.Organisation do
  use Params

  defparams(
    verify_organisation(%{
      name!: :string,
      description: :string,
      metadata: :map,
      app_ids: {:array, :integer}
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
