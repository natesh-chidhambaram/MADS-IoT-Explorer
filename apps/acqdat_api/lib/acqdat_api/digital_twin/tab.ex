defmodule AcqdatApi.DigitalTwin.Tab do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.DigitalTwin.Model.Tab, as: TabModel

  defdelegate update(tab, params), to: TabModel

  def create(params) do
    params = params_extraction(params)
    verify_tab(TabModel.create(params))
  end

  defp verify_tab({:ok, tab}) do
    {:ok, tab}
  end

  defp verify_tab({:error, tab}) do
    {:error, %{error: extract_changeset_error(tab)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
