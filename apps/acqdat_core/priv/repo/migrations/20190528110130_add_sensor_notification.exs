defmodule AcqdatCore.Repo.Migrations.AddSensorNotification do
  use Ecto.Migration

  def change do
    create table("acqdat_sensor_notifications") do
      add(:rule_values, :map)
      add(:sensor_id, references("acqdat_sensors", on_delete: :delete_all), null: false)
      add(:alarm_status, :boolean, default: true)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_sensor_notifications", [:sensor_id])
  end
end
