defmodule AcqdatApiWeb.ToolManagement.ToolTypeView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ToolManagement.ToolTypeView

  def render("tool_type.json", %{tool_type: tool_type}) do
    %{
      tool_type_id: tool_type.id,
      identifier: tool_type.identifier,
      description: tool_type.description
    }
  end

  def render("index.json", tool_type) do
    %{
      tool_type: render_many(tool_type.entries, ToolTypeView, "tool_type.json"),
      page_number: tool_type.page_number,
      page_size: tool_type.page_size,
      total_entries: tool_type.total_entries,
      total_pages: tool_type.total_pages
    }
  end
end
