defmodule AcqdatCore.DigitalTwin.Model.Tab do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.DigitalTwin.Schema.Tab
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = Tab.changeset(%Tab{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Tab, id) do
      nil ->
        {:error, "not found"}

      tab ->
        {:ok, tab}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Tab, query) do
      nil ->
        {:error, "not found"}

      tab ->
        {:ok, tab}
    end
  end

  def update(tab, params) do
    changeset = Tab.update_changeset(tab, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(Tab)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Tab |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_tab_data =
      Tab |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
    tab_data_with_preloads = paginated_tab_data.entries |> Repo.preload(preloads)


    ModelHelper.paginated_response(tab_data_with_preloads, paginated_tab_data)
  end

  def delete(id) do
    Tab
    |> Repo.get(id)
    |> Repo.delete()
  end
end
