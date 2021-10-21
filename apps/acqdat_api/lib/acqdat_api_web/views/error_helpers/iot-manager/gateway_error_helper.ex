defmodule AcqdatApiWeb.IotManager.GatewayErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either Gateway or Project or Organisation with this ID doesn't exists",
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

  def error_message(:elasticsearch, %{error: %{reason: message}}) do
    %{
      title: "ElasticSearch Indexing Problem",
      error: message,
      source: nil
    }
  end

  def error_message(:elasticsearch, message) do
    %{
      title: "There is some problem with elasticsearch.",
      error: message,
      source: nil
    }
  end

  def error_message(:version_updated, message) do
    %{
      title: "Version updated",
      error: "Version has been already updated so kindly fetch the latest one",
      source: message.source
    }
  end
end
