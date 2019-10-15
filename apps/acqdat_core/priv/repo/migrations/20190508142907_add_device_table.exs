defmodule AcqdatCore.Repo.Migrations.AddDeviceTable do
  use Ecto.Migration

  def change do
    create table("acqdat_devices") do
      add(:uuid, :string, null: false)
      add(:name, :string, null: false)
      add(:access_token, :string, null: false)
      add(:description, :text)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_devices", [:name])
    create unique_index("acqdat_devices", [:uuid])
  end
end
