defmodule AcqdatCore.Model.DigitalTwin do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.DigitalTwin
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = DigitalTwin.changeset(%DigitalTwin{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(DigitalTwin, id) do
      nil ->
        {:error, "not found"}

      digital_twin ->
        {:ok, digital_twin}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(DigitalTwin, query) do
      nil ->
        {:error, "not found"}

      digital_twin ->
        {:ok, digital_twin}
    end
  end

  def update(digital_twin, params) do
    changeset = DigitalTwin.update_changeset(digital_twin, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(DigitalTwin)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    DigitalTwin |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_digital_twin_data =
      DigitalTwin |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    digital_twin_data_with_preloads =
      paginated_digital_twin_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(digital_twin_data_with_preloads, paginated_digital_twin_data)
  end

  def delete(id) do
    DigitalTwin
    |> Repo.get(id)
    |> Repo.delete()
  end
end
