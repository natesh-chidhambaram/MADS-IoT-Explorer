defmodule AcqdatCore.Repo.Migrations.AlterUser do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:phone_number, :string)
    end
  end
end
