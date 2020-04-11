defmodule AcqdatApiWeb.Validators.Widgets.User do
  use Params

  defparams(
    verify_user_widget_params(%{
      widget_id!: :integer,
      user_id!: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      user_id: :integer
    })
  )
end
