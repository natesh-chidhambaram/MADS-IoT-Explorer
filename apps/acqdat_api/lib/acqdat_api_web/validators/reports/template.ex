defmodule AcqdatApiWeb.Validators.Reports.Template do
  use Params

  # defparams(
  #   verify_template_params(%{
  #     widget_type_id!: :integer,
  #     label!: :string,
  #     properties!: :map,
  #     policies: :map,
  #     category: {:array, :string},
  #     default_values!: :map,
  #     image_url: :string
  #   })
  # )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
