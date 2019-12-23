defmodule AcqdatCore.Schema.Notification.RangeBased do
  @moduledoc """
  Models range based notifications.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.SensorNotifications
  @behaviour SensorNotifications

  @type t :: %__MODULE__{}
  @rule "RangeBasedPolicy"
  @decimal_zero Decimal.from_float(0.0)

  embedded_schema do
    field(:lower_limit, :decimal, default: 0.0)
    field(:upper_limit, :decimal, default: 0.0)
  end

  def changeset(%__MODULE__{} = rule, params) do
    rule
    |> cast(params, [:lower_limit, :upper_limit])
    |> validate_data()
  end

  @impl SensorNotifications
  def rule_name() do
    @rule
  end

  @impl SensorNotifications
  def rule_preferences(params) do
    %{
      name: @rule,
      rule_data: [
        %{
          key: :lower_limit,
          type: :input,
          value: params["lower_limit"]
        },
        %{
          key: :upper_limit,
          type: :input,
          value: params["upper_limit"]
        }
      ]
    }
  end

  @impl SensorNotifications
  def eligible?(preferences, value) do
    lower_limit = Decimal.cast(preferences["lower_limit"])
    upper_limit = Decimal.cast(preferences["upper_limit"])
    value = Decimal.new(value)

    check_eligibility?(lower_limit, upper_limit, value)
  end

  defp check_eligibility?(@decimal_zero, @decimal_zero, _), do: false

  defp check_eligibility?(lower_limit, @decimal_zero, value) do
    case Decimal.cmp(lower_limit, value) do
      :lt ->
        true

      :eq ->
        true

      _ ->
        false
    end
  end

  defp check_eligibility?(@decimal_zero, upper_limit, value) do
    case Decimal.cmp(value, upper_limit) do
      :lt ->
        false

      :eq ->
        true

      _ ->
        true
    end
  end

  defp check_eligibility?(lower_limit, upper_limit, value) do
    value_lower =
      case Decimal.cmp(lower_limit, value) do
        :lt ->
          true

        :eq ->
          true

        _ ->
          false
      end

    value_upper =
      case Decimal.cmp(upper_limit, value) do
        :gt ->
          true

        :eq ->
          true

        _ ->
          false
      end

    value_lower && value_upper
  end

  defp validate_data(%Ecto.Changeset{valid?: true} = changeset) do
    {:ok, lower_limit} = fetch_change(changeset, :lower_limit)
    {:ok, upper_limit} = fetch_change(changeset, :upper_limit)

    case Decimal.cmp(lower_limit, upper_limit) do
      :lt ->
        changeset

      :eq ->
        changeset

      _ ->
        Ecto.Changeset.add_error(changeset, :lower_limit, "lower limit should be less than upper")
    end
  end

  defp validate_data(changeset), do: changeset
end
