defmodule AcqdatApiWeb.DigitalTwin.TabView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DigitalTwin.TabView

  def render("tab.json", %{tab: tab}) do
    %{
      id: tab.id,
      name: tab.name,
      org_id: tab.org_id,
      image_url: tab.image_url,
      digital_twin_id: tab.digital_twin_id,
      inserted_at: tab.inserted_at
      description: tab.description,
      image_settings: tab.settings
    }
  end

  def render("index.json", tab) do
    %{
      tab:
        render_many(tab.entries, TabView, "tab.json"),
      page_number: tab.page_number,
      page_size: tab.page_size,
      total_entries: tab.total_entries,
      total_pages: tab.total_pages
    }
  end
end
