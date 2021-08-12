defmodule AcqdatApiWeb.EntityManagement.SensorTypeErrorHelper do
  def error_message(:resource_not_found) do
    %{
      title: "Invalid entity ID",
      error: "Either Sensor Type or Project or Organisation with this ID doesn't exists",
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

  def error_message(:sensor_association, message) do
    %{
      title: "Sensor is associated with this sensor type",
      error: message,
      source: nil
    }
  end

  def error_message(:error_association, %{
        error: error,
        source: %{metadata: meta_error, parameters: param_error},
        title: title
      }) do
    %{
      title: title,
      error: error,
      source: %{metadata: from_map_to_list(meta_error), parameters: from_map_to_list(param_error)}
    }
  end

  def error_message(:error_association, %{
        error: error,
        source: %{parameters: message},
        title: title
      }) do
    %{
      title: title,
      error: error,
      source: %{parameters: from_map_to_list(message)}
    }
  end

  def error_message(:error_association, %{
        error: error,
        source: %{metadata: message},
        title: title
      }) do
    %{
      title: title,
      error: error,
      source: %{metadata: from_map_to_list(message)}
    }
  end

  def error_message(:error_association, message) do
    message
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

  defp from_map_to_list(errors) when is_list(errors) do
    error = List.first(errors)

    case is_binary(error) do
      true ->
        errors

      false ->
        Enum.reduce(errors, [], fn error, acc ->
          acc ++ Map.values(error)
        end)
        |> Enum.uniq()
    end
  end

  defp from_map_to_list(error) when is_binary(error) do
    [error]
  end
end
