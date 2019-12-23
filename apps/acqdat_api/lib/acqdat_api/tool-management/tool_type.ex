defmodule AcqdatApi.ToolManagement.ToolType do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.ToolManagement.ToolType, as: ToolTypeModel

  def create(params) do
    %{
      identifier: identifier,
      description: description
    } = params

    verify_tool_type(
      ToolTypeModel.create(%{
        identifier: identifier,
        description: description
      })
    )
  end

  defp verify_tool_type({:ok, tool_type}) do
    {:ok,
     %{
       id: tool_type.id,
       identifier: tool_type.identifier,
       description: tool_type.description
     }}
  end

  defp verify_tool_type({:error, tool_type}) do
    {:error, %{error: extract_changeset_error(tool_type)}}
  end
end
