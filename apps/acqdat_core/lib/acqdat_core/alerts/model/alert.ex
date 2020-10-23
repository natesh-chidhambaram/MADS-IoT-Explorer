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

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}, params) do
    query =
      Alert
      |> where([alert], alert.org_id == ^org_id)
      |> where(^filter_where(params))

    query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Alert |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"name", name}, dynamic_query ->
        dynamic(
          [alert],
          ^dynamic_query and alert.name == ^name
        )

      {"app", app}, dynamic_query ->
        app = String.to_atom(app)

        dynamic(
          [alert],
          ^dynamic_query and alert.app == ^app
        )

      {"status", status}, dynamic_query ->
        status = String.to_atom(status)

        dynamic(
          [alert],
          ^dynamic_query and alert.status == ^status
        )

      {"start_date", start_date}, dynamic_query ->
        end_date = params["end_date"]

        dynamic(
          [alert],
          ^dynamic_query and
            fragment("?::date BETWEEN ? AND ?", alert.inserted_at, ^start_date, ^end_date)
        )

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end

  def delete(alert) do
    case Repo.delete(alert) do
      {:ok, alert} -> {:ok, alert}
      {:error, gateway} -> {:error, gateway}
    end
  end
end
