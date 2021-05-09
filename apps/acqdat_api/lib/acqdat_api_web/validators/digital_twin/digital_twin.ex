defmodule AcqdatApiWeb.Validators.DigitalTwin.DigitalTwin do
  use Params

  defparams(
    verify_digital_twin_params(%{
      name!: :string,
      org_id!: :integer,
      project_id!: :integer,
      creator_id!: :integer,
      opened_on!: :utc_datetime,
      metadata: :map,
      description: :string,
      settings: :map
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      project_id!: :integer
    })
  )
end
