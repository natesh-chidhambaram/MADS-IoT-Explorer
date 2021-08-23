defmodule AcqdatCore.Schema.IoTManager.SensorDataError do
  @moduledoc """
  Schema to define errors for a sensors data.

  Errors occur if data type doesn't justifies the value getting inserted. The error details
  are stored in the db so the user can see and take corrective actions.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Sensor

  schema("acqdat_sensor_error") do
    field(:data, {:array, :map})
    field(:error, :map)

    belongs_to(:sensor, Sensor, on_replace: :raise)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required ~w(data error sensor_id)a

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @required)
    |> validate_required(@required)
    |> assoc_constraint(:sensor)
  end
end
