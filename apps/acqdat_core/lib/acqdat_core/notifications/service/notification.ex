defmodule AcqdatCore.Notifications.Service.Notification do
  alias AcqdatCore.Notifications.Model.Notification
  alias Ecto.Multi
  alias AcqdatCore.Repo

  def process(%{user_id: user_id, org_uuid: org_uuid} = payload) do
    Multi.new()
    |> Multi.run(:save_to_database, fn _, _changes ->
      Notification.create(payload)
    end)
    |> Multi.run(:pub_to_channel, fn _, %{save_to_database: notification} ->
      res =
        AcqdatApiWeb.Endpoint.broadcast("users:#{user_id}", "out_put_res", %{
          notification: notification
        })

      {:ok, notification}
    end)
    |> run_transaction()
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{save_to_database: notification, pub_to_channel: _panel}} ->
        {:ok, notification}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end
end
