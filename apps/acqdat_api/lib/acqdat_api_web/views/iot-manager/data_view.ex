defmodule AcqdatApiWeb.IotManager.DataView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.IotManager.DataView

  def render("gateway_index.json", gateway_data) do
    %{
      gateway_data: render_many(gateway_data.entries, DataView, "gateway_data.json"),
      page_number: gateway_data.page_number,
      page_size: gateway_data.page_size,
      total_entries: gateway_data.total_entries,
      total_pages: gateway_data.total_pages
    }
  end

  def render("gateway_data.json", %{data: data}) do
    %{
      parameter_name: Enum.at(data, 0),
      parameter_uuid: Enum.at(data, 1),
      inserted_timestamp: Enum.at(data, 2),
      value: Enum.at(data, 3),
      gateway_id: Enum.at(data, 4)
    }
  end
end
