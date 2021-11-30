defmodule AcqdatApiWeb.Validators.Reports.WidgetMould do
  use Params

  defparams(
    verify_widget_params(%{
      widget_type_id!: :integer,
      label!: :string,
      properties!: :map,
      policies: :map,
      category: {:array, :string},
      default_values!: :map,
      image_url: :string
    })
  )

  defparams(
    verify_widget_params(%{
      label: :string,
      slug: :string,
      widget_seetings: :map,

    })
  )

end
