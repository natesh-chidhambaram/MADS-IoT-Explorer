defmodule AcqdatApiWeb.Metrics.ReportsErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid resource ID",
      error: "Resource with this ID doesn't exists",
      source: nil
    }
  end

  def error_message(:unauthorized) do
    %{
      title: "Unauthorized Access",
      error: "You are not allowed to perform this action",
      source: nil
    }
  end

  def error_message(:gen_report_error, message) do
    %{
      title: "Error while generating report",
      error: message,
      source: nil
    }
  end

  def error_message(:malformed_data, errors),
    do: errors
end
