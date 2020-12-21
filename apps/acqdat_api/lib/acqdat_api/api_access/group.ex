defmodule AcqdatApi.ApiAccess.Group do
  @moduledoc """
  All the helper function will be provided to the controller through this file
  """
  alias AcqdatCore.Model.RoleManagement.Group
  import AcqdatApiWeb.Helpers

  def create(params) do
    params = params_extraction(params)
    verify_group(Group.create(params))
  end

  defp verify_group({:ok, group}) do
    {:ok, group}
  end

  defp verify_group({:error, group}) do
    {:error, %{error: extract_changeset_error(group)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
