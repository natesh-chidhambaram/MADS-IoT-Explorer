defmodule AcqdatCore.Repo.Migrations.CreateNotificationsTable do
  use Ecto.Migration

  def change do
    create table("acqdat_notifications") do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:user_id, :integer, null: false)
      add(:org_uuid, :string, null: false)
      add(:status, NotificationStatusEnum.type(), null: false)
      add(:app, :string)
      add(:content_type, :string, default: "text")
      add(:payload, :map)
      add(:metadata, :map)
      timestamps(type: :timestamptz)
    end

    create index(:acqdat_notifications, [:user_id, :org_uuid])
    create unique_index(:acqdat_notifications, [:name, :user_id, :org_uuid], name: :unique_name_per_user)
  end
end
