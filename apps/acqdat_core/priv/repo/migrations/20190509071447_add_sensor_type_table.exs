defmodule AcqdatCore.Repo.Migrations.AddSensorTypeTable do
  use Ecto.Migration

  def change do
    create table("acqdat_sensor_types") do
      add(:name, :string, null: false)
      add(:make, :text)
      add(:visualizer, :string)
      add(:identifier, :string, null: false)
      add(:value_keys, {:array, :string}, null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_sensor_types", [:name])
    create unique_index("acqdat_sensor_types", [:identifier])
  end
end
