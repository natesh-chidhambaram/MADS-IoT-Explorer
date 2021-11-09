defmodule AcqdatApiWeb.Validators.Reports.WidgetInstance do
  use Params

  defparams(
    verify_params(%{
      label!: :string,
      org_id!: :integer,
      widget_id!: :integer,
      template_instance_id!: :integer,
      widget_settings: :map,
      visual_properties: :map,
      series_data: [field: {:array, :map}, default: []],
      filter_metadata: :map
    })
  )
end
