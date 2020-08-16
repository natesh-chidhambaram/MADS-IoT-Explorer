defmodule AcqdatCore.Alerts.Policies.LowerThreshold do
  @moduledoc """
  This module will define lower threshold.
  So if any entity implements this policy as an alert rule for a particular parameter. it has to give lower limit value.
  If that parameters value at the time of data parsing gets below this lower limit then that alert rule will generate an alert
  depending upon the severity.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Alerts.Behaviour.Policy
  @behaviour Policy

  @type t :: %__MODULE__{}
  @rule "Alert when data is lesser then a lower threshold"
  @decimal_zero Decimal.from_float(0.0)

  embedded_schema do
    field(:lower_limit, :decimal, default: 0.0)
  end

  def changeset(%__MODULE__{} = rule, params) do
    rule
    |> cast(params, [:lower_limit])
  end

  ############################# BEHAVIOURS IMPLEMENTATION ####################################

  @doc """
  It is implementing the rule name function of the policy and will be returning the policy name.
  """
  @impl Policy
  def rule_name() do
    @rule
  end

  @doc """
  So this rule preference will pass the map which will take a param from alert rule and accordingly create a rule preference which
  will be stored in the alert rules table so that the entity over which this policy is user will act on values extracted from this rule_preference
  """
  @impl Policy
  def rule_preferences() do
    [
      %{
        key: :lower_limit,
        type: :input
      }
    ]
  end

  @doc """
  Here preferences will have lower limit and accordingly we will check for a condition inside check_eligibility function
  """
  @impl Policy
  def eligible?(preferences, value) do
    lower_limit = Decimal.new(preferences["lower_limit"])
    value = Decimal.new(value)
    check_eligibility?(lower_limit, @decimal_zero, value)
  end

  # This is for the case when both our limit comes as zero
  defp check_eligibility?(@decimal_zero, @decimal_zero, _), do: false

  # This is for the case when upper limit is zero so basically we are checking for lesser then lower limit criteria.
  defp check_eligibility?(lower_limit, @decimal_zero, value) do
    case Decimal.cmp(value, lower_limit) do
      :lt ->
        false

      :eq ->
        false

      _ ->
        true
    end
  end
end
