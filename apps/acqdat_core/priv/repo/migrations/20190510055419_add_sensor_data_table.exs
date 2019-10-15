defmodule AcqdatCore.Repo.Migrations.AddSensorDataTable do
  use Ecto.Migration

  def change do
    create table("acqdat_sensor_data") do
      add(:inserted_timestamp, :timestamptz, null: false)
      add(:datapoint, :map, null: false)
      add(:sensor_id, references("acqdat_sensors", on_delete: :restrict), null: false)

      timestamps(type: :timestamptz)
    end
  end
end
