defmodule AcqdatCore.Repo.Migrations.CreateCockpitUser do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table(:cockpit_users) do
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :citext, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:password_hash, :string, null: false)
      add(:phone_number, :string)
      add(:avatar, :string)
      add(:status, :string, default: "init")

      timestamps(type: :timestamptz)
    end

    create unique_index("cockpit_users", [:email])
  end
end
