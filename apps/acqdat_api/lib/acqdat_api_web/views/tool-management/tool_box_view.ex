defmodule AcqdatApiWeb.ToolManagement.ToolBoxView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ToolManagement.ToolBoxView

  def render("tool_box.json", %{tool_box: tool_box}) do
    %{
      tool_box_id: tool_box.id,
      name: tool_box.name,
      uuid: tool_box.uuid,
      description: tool_box.description
    }
  end

  def render("index.json", tool_box) do
    %{
      tool_box: render_many(tool_box.entries, ToolBoxView, "tool_box.json"),
      page_number: tool_box.page_number,
      page_size: tool_box.page_size,
      total_entries: tool_box.total_entries,
      total_pages: tool_box.total_pages
    }
  end
end
