defmodule AcqdatApi.Alerts.Alert do
  @moduledoc """
  All the helper function will be provided to the controller through this file
  """

  alias AcqdatCore.Alerts.Model.Alert
  import AcqdatApiWeb.Helpers

  defdelegate update(alert, params), to: Alert
  defdelegate get_all(data), to: Alert
  defdelegate delete(alert), to: Alert

  def create(params) do
    params = params_extraction(params)
    verify_alert(Alert.create(params))
  end

  def verify_alert({:ok, alert_rules}) do
    {:ok, alert_rules}
  end

  def verify_alert({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
