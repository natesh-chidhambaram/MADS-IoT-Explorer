defmodule AcqdatApiWeb.Validators.DashboardManagement.Subpanel do
  use Params

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      dashboard_id!: :integer,
      panel_id!: :integer
    })
  )

  defparams(
    verify_create_params(%{
      org_id!: :integer,
      dashboard_id!: :integer,
      panel_id!: :integer,
      name!: :string,
      icon!: :string,
      description: :string,
      settings: :map,
      widget_layouts: :map,
      filter_metadata: :map
    })
  )
end
