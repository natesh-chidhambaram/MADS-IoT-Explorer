defmodule AcqdatCore.Repo.Migrations.AddDigitalTwinTable do
  use Ecto.Migration

  def change do
    create table("acqdat_digital_twins") do
      add(:name, :string, null: false)
      timestamps(type: :timestamptz)
    end
  end
end
