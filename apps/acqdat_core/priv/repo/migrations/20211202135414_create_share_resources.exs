defmodule AcqdatCore.Repo.Migrations.CreateShareResources do
  use Ecto.Migration

  def change do
    create table("share_resources") do
      add(:resource_type_id, :integer, null: false)
      add(:resource_id, :integer, null: false)
      add(:cockpit_user_id, references(:cockpit_users, on_delete: :nothing), null: false)
      add(:share_by_user_id, references(:users, on_delete: :nothing), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("share_resources", [:resource_type_id, :resource_id, :cockpit_user_id])
  end
end
