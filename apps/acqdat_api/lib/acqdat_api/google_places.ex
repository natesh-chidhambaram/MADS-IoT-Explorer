defmodule AcqdatApi.GooglePlaces do
  def find_place(search_string) when is_binary(search_string) do
    verify_places(GoogleMaps.geocode(search_string))
  end

  defp verify_places({:ok, details}) do
    {:ok, details}
  end

  defp verify_places({:error, error_message}) do
    {:error, error_message}
  end
end
