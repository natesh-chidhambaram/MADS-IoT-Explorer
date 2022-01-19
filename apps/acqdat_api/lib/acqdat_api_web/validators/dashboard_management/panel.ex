defmodule AcqdatApiWeb.Validators.DashboardManagement.Panel do
  use Params

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      dashboard_id!: :integer
    })
  )

  defparams(
    verify_create(%{
      org_id!: :integer,
      dashboard_id!: :integer,
      name!: :string,
      icon!: :string,
      description: :string,
      settings: :map,
      widget_layouts: :map,
      filter_metadata: :map
    })
  )

  @doc """
  For panel duplication, if the received request contains value for parent-id, then the target is going to be subpanel which comes under the received parent-id.
  Else the target is going to be the root panel.
  optional_params:- parent_id
  """

  defparams(
    verify_duplicate(%{
      org_id!: :integer,
      name!: :string,
      icon!: :string,
      panel_id!: :integer,
      parent_id: :integer,
      target_dashboard_id!: :integer
    })
  )
end
