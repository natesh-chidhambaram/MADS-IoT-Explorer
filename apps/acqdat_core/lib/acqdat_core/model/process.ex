defmodule AcqdatCore.Model.Process do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.Process
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = Process.changeset(%Process{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Process, id) do
      nil ->
        {:error, "not found"}

      process ->
        {:ok, process}
    end
  end

  def get(query) when is_map(query) do
    case Repo.get_by(Process, query) do
      nil ->
        {:error, "not found"}

      process ->
        {:ok, process}
    end
  end

  def update(process, params) do
    changeset = Process.update_changeset(process, params)
    Repo.update(changeset)
  end

  def get_all() do
    Repo.all(Process)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Process |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_process_data =
      Process |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    process_data_with_preloads = paginated_process_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(process_data_with_preloads, paginated_process_data)
  end

  def delete(id) do
    Process
    |> Repo.get(id)
    |> Repo.delete()
  end
end
