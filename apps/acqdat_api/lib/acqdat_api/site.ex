defmodule AcqdatApi.Site do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.Site, as: SiteModel

  def create(params) do
    %{
      name: name,
      location_details: location_details,
      image_url: image_url
    } = params

    verify_site(
      SiteModel.create(%{
        name: name,
        location_details: location_details,
        image_url: image_url
      })
    )
  end

  defp verify_site({:ok, site}) do
    {:ok,
     %{
       id: site.id,
       name: site.name,
       location_details: site.location_details,
       image_url: site.image_url
     }}
  end

  defp verify_site({:error, site}) do
    {:error, %{error: extract_changeset_error(site)}}
  end
end
