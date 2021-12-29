defmodule AcqdatApi.EntityManagement.AlertRules do
  @moduledoc """
  All the helper functions related to alert rules are either written here or being accessed from here
  """
  alias AcqdatCore.Model.EntityManagement.AlertRules
  import AcqdatApiWeb.Helpers
  defdelegate update(alert_rules, params), to: AlertRules
  defdelegate get_all(data), to: AlertRules
  defdelegate delete(alert_rules), to: AlertRules

  defdelegate list_policies(), to: AlertRules

  def create(params) do
    params = params_extraction(params)
    verify_alert_rules(AlertRules.create(params))
  end


  defp verify_alert_rules({:ok, alert_rules}) do
    {:ok, alert_rules}
  end

  defp verify_alert_rules({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
