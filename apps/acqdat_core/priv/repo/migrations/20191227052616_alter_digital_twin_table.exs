defmodule AcqdatCore.Repo.Migrations.AlterDigitalTwinTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_digital_twins") do
      add(:metadata, :map)
    end
  end
end
