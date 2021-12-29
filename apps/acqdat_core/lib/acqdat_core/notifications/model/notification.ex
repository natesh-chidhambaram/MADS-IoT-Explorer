defmodule AcqdatCore.Notifications.Model.Notification do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Notifications.Schema.Notification

  def create(params) do
    changeset = Notification.changeset(%Notification{}, params)
    Repo.insert(changeset)
  end

  def update(id, params) do
    case Repo.get(Notification, id) do
      nil ->
        {:error, "Notification not found"}

      notification ->
        changeset = Notification.changeset(notification, params)
        Repo.update(changeset)
    end
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Notification, id) do
      nil ->
        {:error, "Notification not found"}

      notification ->
        {:ok, notification}
    end
  end

  def get_all_by_user(user_id, org_uuid) do
    query =
      Notification
      |> where(
        [notification],
        notification.org_uuid == ^org_uuid and notification.user_id == ^user_id
      )
      |> order_by(desc: :inserted_at)
      |> Repo.all()
  end
end
