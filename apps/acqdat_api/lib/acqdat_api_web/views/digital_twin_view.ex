defmodule AcqdatApiWeb.DigitalTwinView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.SiteView
  alias AcqdatApiWeb.ProcessView
  alias AcqdatApiWeb.DigitalTwinView

  def render("digital_twin.json", %{digital_twin: digital_twin}) do
    %{
      id: digital_twin.id,
      name: digital_twin.name,
      site_id: digital_twin.site_id,
      process_id: digital_twin.process_id
    }
  end

  def render("digital_twin_with_preloads.json", %{digital_twin: digital_twin}) do
    %{
      id: digital_twin.id,
      name: digital_twin.name,
      site_id: digital_twin.site_id,
      process_id: digital_twin.process_id,
      site: render_one(digital_twin.site, SiteView, "site.json"),
      process: render_one(digital_twin.process, ProcessView, "process.json")
    }
  end

  def render("index.json", digital_twin) do
    %{
      digital_twin:
        render_many(digital_twin.entries, DigitalTwinView, "digital_twin_with_preloads.json"),
      page_number: digital_twin.page_number,
      page_size: digital_twin.page_size,
      total_entries: digital_twin.total_entries,
      total_pages: digital_twin.total_pages
    }
  end
end
