defmodule AcqdatCore.Model.Site do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.Site
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = Site.changeset(%Site{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Site, id) do
      nil ->
        {:error, "not found"}

      site ->
        {:ok, site}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Site, query) do
      nil ->
        {:error, "not found"}

      site ->
        {:ok, site}
    end
  end

  def update(site, params) do
    changeset = Site.update_changeset(site, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(Site)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Site |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_site_data =
      Site |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    site_data_with_preloads = paginated_site_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(site_data_with_preloads, paginated_site_data)
  end

  def delete(id) do
    Site
    |> Repo.get(id)
    |> Repo.delete()
  end
end
