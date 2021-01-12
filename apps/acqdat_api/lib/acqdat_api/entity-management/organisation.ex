defmodule AcqdatApi.EntityManagement.Organisation do
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo

  defdelegate get(id), to: OrgModel
  defdelegate update(org, data), to: OrgModel
  defdelegate get_all(data, preloads), to: OrgModel
  defdelegate delete(org), to: OrgModel

  def create(params) do
    params = params_extraction(params)
    verify_organisation(OrgModel.create(params))
  end

  defp verify_organisation({:ok, org}) do
    {:ok, org}
  end

  defp verify_organisation({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
