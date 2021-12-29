defmodule AcqdatApi.Utils.Helper do
  def string_to_date(date) do
    date
    |> Timex.parse("{YYYY}-{0M}-{D}")
    |> elem(1)
    |> Timex.to_date()
  end

  def convert_group_action_to_days("daily"), do: 0
  def convert_group_action_to_days("weekly"), do: 7
  def convert_group_action_to_days("monthly"), do: 30
  def convert_group_action_to_days("quaterly"), do: 90
  def convert_group_action_to_days("yearly"), do: 365
end
