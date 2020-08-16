defmodule AcqdatCore.Alerts.Model.Alert do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Alerts.Schema.Alert

  def create(params) do
    changeset = Alert.changeset(%Alert{}, params)
    Repo.insert(changeset)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Alert, id) do
      nil ->
        {:error, "Alert not found"}

      alert ->
        {:ok, alert}
    end
  end

  def update(%Alert{} = alert, params) do
    changeset = Alert.changeset(alert, params)

    case Repo.update(changeset) do
      {:ok, alert} -> {:ok, alert}
      {:error, alert} -> {:error, alert}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number, filters: _filters}) do
    Alert |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Alert |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def delete(alert) do
    case Repo.delete(alert) do
      {:ok, alert} -> {:ok, alert}
      {:error, gateway} -> {:error, gateway}
    end
  end
end
