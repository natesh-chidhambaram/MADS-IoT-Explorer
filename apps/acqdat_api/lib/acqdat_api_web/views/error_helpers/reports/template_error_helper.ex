defmodule AcqdatApiWeb.Reports.TemplateErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid Template ID",
      error: "Template with this ID does not exists",
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
