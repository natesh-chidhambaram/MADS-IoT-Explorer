defmodule AcqdatCore.Repo.Migrations.AddSiteTable do
  use Ecto.Migration

  def change do
    create table("acqdat_sites") do
      add(:name, :string, null: false)
      timestamps(type: :timestamptz)
    end
    create unique_index("acqdat_sites", [:name])
  end
end
