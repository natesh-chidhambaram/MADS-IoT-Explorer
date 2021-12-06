defmodule AcqdatCore.Repo.Migrations.CreateCockpitUsers do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    # @primary_key false
    create table("cockpit_users", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :citext, null: false)
      add(:password_hash, :string, null: false)
      add(:phone_number, :string)
      add(:avatar, :string)

      timestamps(type: :timestamptz)
    end

    create unique_index("cockpit_users", [:email])
  end
end
