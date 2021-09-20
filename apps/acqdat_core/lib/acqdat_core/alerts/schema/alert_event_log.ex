defmodule AcqdatCore.Alerts.Schema.AlertEventLog do
  use AcqdatCore.Schema

  alias AcqdatCore.Alerts.Schema.Alert

  schema "acqdat_alert_event_log" do
    field(:inserted_timestamp, :utc_datetime)
    field(:name, :string)
    field(:description, :string)
    field(:severity, AlertSeverityEnum)
    field(:alert_metadata, :map)

    belongs_to(:alert, Alert)
  end

  @params ~w(name severity description inserted_timestamp alert_metadata alert_id)a

  def changeset(%__MODULE__{} = event, params) do
    event
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
