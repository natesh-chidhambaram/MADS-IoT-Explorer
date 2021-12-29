defmodule AcqdatApiWeb.Validators.Metrics.ValidateData do
  alias AcqdatApi.Utils.Helper

  def validate_params(params) do
    with %{
           "end_date" => end_date,
           "group_action" => group_action,
           "start_date" => start_date,
           "type" => type
         } = params <- update_params_value(params),
         true <- is_valid_group_action(group_action),
         true <- is_valid_type(type),
         true <- is_group_action_in_date_range(start_date, end_date, group_action) do
      {:ok, params}
    else
      :invalid_group_action -> {:validation_error, "Invalid group action"}
      :invalid_type -> {:validation_error, "Invalid type"}
      :invalid_date_range -> {:validation_error, "Date range is lesser than group action"}
    end
  end

  defp update_params_value(%{"group_action" => group_action, "type" => type} = params) do
    Map.merge(params, %{
      "group_action" => String.downcase(group_action),
      "type" => String.downcase(type)
    })
  end

  defp is_valid_group_action(group_action)
       when group_action in ["daily", "weekly", "monthly", "quaterly", "yearly"],
       do: true

  defp is_valid_group_action(_group_action), do: :invalid_group_action

  defp is_valid_type(type) when type in ["column", "cards", "list", "highlights"], do: true
  defp is_valid_type(_type), do: :invalid_type

  defp is_group_action_in_date_range(start_date, end_date, group_action) do
    date_diff =
      start_date
      |> Helper.string_to_date()
      |> get_date_diff(Helper.string_to_date(end_date))

    if date_diff >= Helper.convert_group_action_to_days(group_action),
      do: true,
      else: :invalid_date_range
  end

  defp get_date_diff(date1, date2), do: Date.diff(date2, date1)
end
