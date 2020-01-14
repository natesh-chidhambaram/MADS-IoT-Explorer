defmodule AcqdatApi.Device do
  alias AcqdatCore.Model.Device, as: DeviceModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      name: name,
      access_token: access_token,
      description: description,
      site_id: site_id,
      image_url: image_url
    } = params

    verify_device(
      DeviceModel.create(%{
        name: name,
        access_token: access_token,
        description: description,
        site_id: site_id,
        image_url: image_url
      })
    )
  end

  defp verify_device({:ok, device}) do
    {:ok,
     %{
       id: device.id,
       name: device.name,
       access_token: device.access_token,
       description: device.description,
       uuid: device.uuid,
       site_id: device.site_id,
       image_url: device.image_url
     }}
  end

  defp verify_device({:error, device}) do
    {:error, %{error: extract_changeset_error(device)}}
  end

  def device_by_criteria(%{"site_id" => site_id} = _criteria) do
    {site_id, _} = Integer.parse(site_id)
    {:list, DeviceModel.get_all_by_criteria(site_id, [:site])}
  end
end
