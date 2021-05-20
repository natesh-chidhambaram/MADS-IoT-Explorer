defmodule AcqdatApiWeb.DigitalTwin.TabErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid Resource ID",
      error: "Either Digital Twin ID or Organisation or Tab with this ID doesn't exists",
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
end
