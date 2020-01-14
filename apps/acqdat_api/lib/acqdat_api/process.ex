defmodule AcqdatApi.Process do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.Process, as: ProcessModel

  def create(params) do
    %{
      name: name,
      site_id: site_id,
      image_url: image_url
    } = params

    verify_process(
      ProcessModel.create(%{
        name: name,
        site_id: site_id,
        image_url: image_url
      })
    )
  end

  defp verify_process({:ok, process}) do
    {:ok,
     %{
       id: process.id,
       name: process.name,
       site_id: process.site_id,
       image_url: process.image_url
     }}
  end

  defp verify_process({:error, process}) do
    {:error, %{error: extract_changeset_error(process)}}
  end
end
