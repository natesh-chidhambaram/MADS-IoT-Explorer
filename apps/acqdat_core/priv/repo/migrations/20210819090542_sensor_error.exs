defmodule AcqdatCore.Repo.Migrations.SensorError do
  use Ecto.Migration

  def change do
    create table("acqdat_sensor_error") do
      add(:data, {:array, :map}, null: false)
      add(:error, :map, null: false)
      add(:sensor_id, references("acqdat_sensors", on_delete: :restrict), null: false)

      timestamps(type: :timestamptz, updated_at: false)
    end
  end
end
