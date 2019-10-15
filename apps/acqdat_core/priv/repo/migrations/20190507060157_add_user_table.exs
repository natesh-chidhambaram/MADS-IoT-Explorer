defmodule AcqdatCore.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")

    create table("users") do
      add(:first_name, :string, null: false)
      add(:last_name, :string)
      add(:email, :citext, null: false)
      add(:password_hash, :string, null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("users", [:email])
  end
end
