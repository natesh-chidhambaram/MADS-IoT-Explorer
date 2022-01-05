defmodule AcqdatApiWeb.DashboardManagement.PanelErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Panel with this ID does not exists",
      source: nil
    }
  end

  def error_message(:unauthorized) do
    %{
      title: "Unauthorized Access",
      error: "You are not allowed to perform this action.",
      source: nil
    }
  end

  def error_message(:not_found, reason \\ "Not found") do
    %{
      title: :not_found,
      error: reason,
      source: nil
    }
  end
end
