defmodule AcqdatApi.DigitalTwin do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.DigitalTwin, as: DigitalTwinModel

  def create(params) do
    %{
      name: name,
      process_id: process_id,
      site_id: site_id
    } = params

    verify_digital_twin(
      DigitalTwinModel.create(%{
        name: name,
        process_id: process_id,
        site_id: site_id
      })
    )
  end

  defp verify_digital_twin({:ok, digital_twin}) do
    {:ok,
     %{
       id: digital_twin.id,
       name: digital_twin.name,
       process_id: digital_twin.process_id,
       site_id: digital_twin.site_id
     }}
  end

  defp verify_digital_twin({:error, digital_twin}) do
    {:error, %{error: extract_changeset_error(digital_twin)}}
  end
end
