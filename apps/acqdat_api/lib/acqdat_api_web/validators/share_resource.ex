defmodule AcqdatApiWeb.Validators.ShareResource do
  use Params

  defparams(
    validate_resource_sharing_data(%{
      org_id!: :string,
      resource_type!: :string,
      resource_id!: :string,
      share_with!: [:string]
    })
  )
end
