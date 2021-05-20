defmodule AcqdatApi.DigitalTwin.DigitalTwin do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.DigitalTwin.Model.DigitalTwin, as: DigitalTwinModel

  def create(params) do
    params = params_extraction(params)

    verify_digital_twin(DigitalTwinModel.create(params))
  end

  defp verify_digital_twin({:ok, digital_twin}) do
    {:ok, digital_twin}
  end

  defp verify_digital_twin({:error, digital_twin}) do
    {:error, %{error: extract_changeset_error(digital_twin)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
