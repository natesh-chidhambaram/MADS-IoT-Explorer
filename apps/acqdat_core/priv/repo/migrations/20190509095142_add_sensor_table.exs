defmodule AcqdatCore.Repo.Migrations.AddSensorTable do
  use Ecto.Migration

  def change do
    create table("acqdat_sensors") do
      add(:uuid, :string, null: false)
      add(:name, :string, null: false)

      timestamps(type: :timestamptz)
    end    
  end
end
