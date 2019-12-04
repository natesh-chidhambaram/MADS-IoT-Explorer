defmodule AcqdatApi.ToolManagement.Tool do
  alias AcqdatCore.Model.ToolManagement.Tool, as: ToolModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      name: name,
      status: status,
      description: description,
      tool_box_id: tool_box_id,
      tool_type_id: tool_type_id
    } = params

    verify_tool(
      ToolModel.create(%{
        name: name,
        status: status,
        description: description,
        tool_box_id: tool_box_id,
        tool_type_id: tool_type_id
      })
    )
  end

  defp verify_tool({:ok, tool}) do
    {:ok,
     %{
       id: tool.id,
       name: tool.name,
       status: tool.status,
       description: tool.description,
       tool_box_id: tool.tool_box_id,
       tool_type_id: tool.tool_type_id,
       uuid: tool.uuid
     }}
  end

  defp verify_tool({:error, tool}) do
    {:error, %{error: extract_changeset_error(tool)}}
  end
end
