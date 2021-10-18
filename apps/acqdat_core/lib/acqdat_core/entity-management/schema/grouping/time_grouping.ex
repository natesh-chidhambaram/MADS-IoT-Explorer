defmodule AcqdatCore.EntityManagement.Schema.Grouping.TimeGrouping do
  alias AcqdatCore.EntityManagement.Schema.Grouping

  @behaviour Grouping
  @rule "Group Alerts by Time"

  use AcqdatCore.Schema
  @values ~w(seconds minutes hours days)s

  embedded_schema do
    field(:value, :integer)
    field(:unit, :string)
    field(:previous_time, :utc_datetime)
  end

  @parameters ~w(value unit previous_time)a
  @required ~w(value unit previous_time)a

  def rule_name() do
    @rule
  end

  def rule_preferences() do
    [
      %{
        key: :value,
        type: :integer
      },
      %{
        key: :unit,
        type: [:minutes, :seconds, :hours, :days]
      }
    ]
  end

  def changeset(%__MODULE__{} = grouping, params) do
    grouping
    |> cast(params, @parameters)
    |> validate_required(@required)
    |> validate_inclusion(:unit, @values)
  end

  @impl Grouping
  def run_check?(parameters, token) do
    unit = String.to_existing_atom(parameters["unit"])
    {:ok, time} = Timex.parse(parameters["previous_time"], "{RFC3339z}")
    result = Timex.diff(token.inserted_timestamp, time, unit)
    result > parameters["value"]
  end

  @impl Grouping
  def settings() do
    %{
      value: %{type: "integer"},
      unit: %{
        type: "select",
        data: @values
      }
    }
  end

  @impl Grouping
  def name() do
    "time_grouping"
  end
end
