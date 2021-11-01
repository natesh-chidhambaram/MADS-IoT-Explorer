defmodule AcqdatApiWeb.Validators.Reports.Widget do
  use Params

  defparams(
    verify_widget_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
