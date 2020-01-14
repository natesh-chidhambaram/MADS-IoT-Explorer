defmodule AcqdatApiWeb.DeviceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DeviceView
  alias AcqdatApiWeb.SiteView

  def render("device.json", %{device: device}) do
    %{
      id: device.id,
      name: device.name,
      uuid: device.uuid,
      description: device.description,
      access_token: device.access_token,
      image_url: device.image_url
    }
  end

  def render("device_with_sites.json", %{device: device}) do
    %{
      id: device.id,
      name: device.name,
      uuid: device.uuid,
      description: device.description,
      access_token: device.access_token,
      image_url: device.image_url,
      site_id: device.site_id,
      site: render_one(device.site, SiteView, "site.json")
    }
  end

  def render("device_details.json", %{device: device_by_criteria}) do
    %{
      id: device_by_criteria.id,
      name: device_by_criteria.name,
      uuid: device_by_criteria.uuid,
      description: device_by_criteria.description,
      access_token: device_by_criteria.access_token,
      site_id: device_by_criteria.site_id,
      site: render_one(device_by_criteria.site, SiteView, "site.json")
    }
  end

  def render("device_with_preloads.json", %{device: [device]}) do
    %{
      id: device.id,
      name: device.name,
      uuid: device.uuid,
      description: device.description,
      access_token: device.access_token
    }
  end

  def render("index.json", device) do
    %{
      devices: render_many(device.entries, DeviceView, "device_with_sites.json"),
      page_number: device.page_number,
      page_size: device.page_size,
      total_entries: device.total_entries,
      total_pages: device.total_pages
    }
  end

  def render("device_by_criteria_with_preloads.json", %{device_by_criteria: device_by_criteria}) do
    %{
      devices: render_many(device_by_criteria, DeviceView, "device_details.json")
    }
  end
end
