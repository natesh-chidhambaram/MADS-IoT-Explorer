defmodule AcqdatApiWeb.ProcessView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ProcessView
  alias AcqdatApiWeb.SiteView

  def render("process.json", %{process: process}) do
    %{
      id: process.id,
      name: process.name,
      site_id: process.site_id,
      image_url: process.image_url
    }
  end

  def render("process_with_preloads.json", %{process: process}) do
    %{
      id: process.id,
      name: process.name,
      site_id: process.site_id,
      image_url: process.image_url,
      site: render_one(process.site, SiteView, "site.json")
    }
  end

  def render("index.json", process) do
    %{
      process: render_many(process.entries, ProcessView, "process_with_preloads.json"),
      page_number: process.page_number,
      page_size: process.page_size,
      total_entries: process.total_entries,
      total_pages: process.total_pages
    }
  end
end
