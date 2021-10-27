defmodule AcqdatApiWeb.Notifications.UsersChannel do
  use Phoenix.Channel
  alias AcqdatCore.Notifications.Model.Notification

  intercept ["out_put_res", "out_put_ack_done", "out_put_notifications"]

  def join("users:" <> identifier, _params, socket) do
    if socket.assigns.user_id do
      socket = assign(socket, :identifier, identifier)
      response = %{message: "Channel Joined Successfully #{identifier}"}
      {:ok, response, socket}
    else
      {:error, %{reason: "unauthorized"}, socket}
    end
  end

  def handle_out("out_put_res", res, socket) do
    push(
      socket,
      "out_put_res",
      Phoenix.View.render(
        AcqdatApiWeb.Notifications.NotificationView,
        "notification.json",
        res
      )
    )

    {:noreply, socket}
  end

  def handle_out("out_put_ack_done", %{data: {:error, err_msg}}, socket) do
    push(
      socket,
      "out_put_ack_done",
      %{error: err_msg}
    )

    {:noreply, socket}
  end

  def handle_out("out_put_ack_done", %{data: {:ok, notification}}, socket) do
    push(
      socket,
      "out_put_ack_done",
      Phoenix.View.render(
        AcqdatApiWeb.Notifications.NotificationView,
        "notification.json",
        %{notification: notification}
      )
    )

    {:noreply, socket}
  end

  def handle_out("out_put_notifications", %{data: res}, socket) do
    push(
      socket,
      "out_put_notifications",
      Phoenix.View.render(
        AcqdatApiWeb.Notifications.NotificationView,
        "notification_list.json",
        %{notifications: res}
      )
    )

    {:noreply, socket}
  end

  def handle_in(
        "out_put_ack",
        %{
          "notification_id" => notification_id,
          "status" => status
        },
        socket
      ) do
    status = if status == "read", do: 1, else: 2
    res = Notification.update(notification_id, %{status: status})

    broadcast!(socket, "out_put_ack_done", %{data: res})

    {:reply, :ok, socket}
  end

  def handle_in(
        "fetch_notifications",
        %{
          "user_id" => user_id,
          "org_uuid" => org_uuid
        },
        socket
      ) do
    res = Notification.get_all_by_user(user_id, org_uuid)

    broadcast!(socket, "out_put_notifications", %{data: res})

    {:reply, :ok, socket}
  end
end
