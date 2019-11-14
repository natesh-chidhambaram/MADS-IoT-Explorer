defmodule AcqdatApiWeb.Validators.SensorType do
  @moduledoc """
  Exposes validator functions to validate params for Sensor Type related APIs.
  """

  use Params

  defparams(
    verify_sensor_type_params(%{
      name!: :string,
      identifier!: :string,
      value_keys!: {:array, :string},
      make: :string,
      visualizer: :string
    })
  )
end
