defmodule AcqdatCore.Seed.Notifications.Notification do
  alias AcqdatCore.Notifications.Model.Notification

  def seed() do
    Enum.to_list 1..10
    |> Enum.map(fn idx ->
      params = %{name: "Notification #{idx}_#{UUID.uuid1(:hex)}", org_uuid: "a0ba1adcacb411eb986a0242c0a8300b", payload: %{data: "User Has been created"}, user_id: 1}
      Notification.create(params)
    end)
  end
end
