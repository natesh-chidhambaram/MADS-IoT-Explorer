defmodule AcqdatCore.Notifications.Schema.Notification do
  use AcqdatCore.Schema

  schema "acqdat_notifications" do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:status, NotificationStatusEnum, default: 2)
    field(:user_id, :integer, null: false)
    field(:org_uuid, :string, null: false)
    field(:app, :string)
    field(:content_type, :string, default: "text")
    field(:payload, :map)
    field(:metadata, :map)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name user_id org_uuid payload)a
  @optional_params ~w(description app content_type metadata status)a
  @permitted_params @required_params ++ @optional_params

  def changeset(notification, params) do
    notification
    |> cast(params, @permitted_params)
    |> validate_required(@required_params)
    |> unique_constraint(:name,
      name: :unique_name_per_user,
      message: "unique name under user"
    )
  end
end
