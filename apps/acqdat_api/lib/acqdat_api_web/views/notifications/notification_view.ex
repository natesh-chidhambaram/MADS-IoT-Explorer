defmodule AcqdatApiWeb.Notifications.NotificationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Notifications.NotificationView

  def render("notification.json", %{notification: notification}) do
    %{
      id: notification.id,
      name: notification.name,
      description: notification.description,
      status: notification.status,
      user_id: notification.user_id,
      org_uuid: notification.org_uuid,
      app: notification.app,
      content_type: notification.content_type,
      payload: notification.payload,
      metadata: notification.metadata,
      inserted_at: notification.inserted_at
    }
  end

  def render("notification_list.json", %{notifications: notifications}) do
    %{
      notifications: render_many(notifications, NotificationView, "notification.json")
    }
  end
end
