defmodule AcqdatApiWeb.Validators.DashboardManagement.WidgetInstance do
  use Params

  defparams(
    verify_params(%{
      label!: :string,
      org_id!: :integer,
      widget_id!: :integer,
      panel_id!: :integer,
      widget_settings: :map,
      visual_properties: :map,
      series_data: [field: {:array, :map}, default: []]
    })
  )

  defparams(
    verify_duplicate(%{
      org_id!: :integer,
      widget_id!: :integer,
      # The target panel-Id
      panel_id!: :integer,
      label!: :string
    })
  )
end
