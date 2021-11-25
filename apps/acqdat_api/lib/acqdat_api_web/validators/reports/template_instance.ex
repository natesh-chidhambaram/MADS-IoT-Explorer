defmodule AcqdatApiWeb.Validators.Reports.TemplateInstance do
  use Params

  defparams(
    verify_params(%{
      type!: :string,
      org_id!: :integer,
      name!: :string,
      pages: {:array, :map}
    })
  )

  defparams(
    verify_update_params(%{
      type!: :string,
      org_id!: :integer,
      name!: :string,
      pages: {:array, :map}
    })
  )


  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
