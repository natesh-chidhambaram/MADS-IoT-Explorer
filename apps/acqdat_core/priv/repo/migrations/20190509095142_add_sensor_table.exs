defmodule AcqdatCore.Repo.Migrations.AddSensorTable do
  use Ecto.Migration

  def change do
    create table("acqdat_sensors") do
      add(:uuid, :string, null: false)
      add(:name, :string, null: false)
      add(:device_id, references("acqdat_devices", on_delete: :delete_all), null: false)
      add(:sensor_type_id, references("acqdat_sensor_types", on_delete: :restrict), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_sensors", [:name, :device_id], name: :unique_sensor_per_device)
  end
end
