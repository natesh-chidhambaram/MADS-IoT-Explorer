defmodule AcqdatApi.ToolManagement.ToolBox do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.ToolManagement.ToolBox, as: ToolBoxModel

  def create(params) do
    %{
      name: name,
      description: description
    } = params

    verify_tool_box(
      ToolBoxModel.create(%{
        name: name,
        description: description
      })
    )
  end

  defp verify_tool_box({:ok, tool_box}) do
    {:ok,
     %{
       id: tool_box.id,
       name: tool_box.name,
       description: tool_box.description,
       uuid: tool_box.uuid
     }}
  end

  defp verify_tool_box({:error, tool_box}) do
    {:error, %{error: extract_changeset_error(tool_box)}}
  end
end
