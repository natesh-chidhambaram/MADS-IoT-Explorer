defmodule AcqdatApiWeb.ToolManagement.ToolView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ToolManagement.ToolView
  alias AcqdatApiWeb.ToolManagement.ToolTypeView
  alias AcqdatApiWeb.ToolManagement.ToolBoxView

  def render("tool.json", %{tool: tool}) do
    %{
      tool_id: tool.id,
      name: tool.name,
      status: tool.status,
      description: tool.description,
      uuid: tool.uuid,
      tool_type: render_one(tool.tool_type, ToolTypeView, "tool_type.json"),
      tool_box: render_one(tool.tool_box, ToolBoxView, "tool_box.json")
    }
  end

  def render("tool_for_create.json", %{tool: tool}) do
    %{
      tool_id: tool.id,
      name: tool.name,
      status: tool.status,
      description: tool.description,
      uuid: tool.uuid
    }
  end

  def render("tool_with_preloads.json", %{tool: tool}) do
    %{
      tool_id: tool.id,
      name: tool.name,
      status: tool.status,
      description: tool.description,
      uuid: tool.uuid,
      tool_type: render_one(tool.tool_type, ToolTypeView, "tool_type.json"),
      tool_box: render_one(tool.tool_box, ToolBoxView, "tool_box.json")
    }
  end

  def render("index.json", tool) do
    %{
      tools: render_many(tool.entries, ToolView, "tool_with_preloads.json"),
      page_number: tool.page_number,
      page_size: tool.page_size,
      total_entries: tool.total_entries,
      total_pages: tool.total_pages
    }
  end
end
