defmodule AcqdatCore.Repo.Migrations.AcqdatGroups do
  use Ecto.Migration

  def change do
    create table("acqdat_groups") do
      add(:name, :string, null: false)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_groups", [:name, :org_id])
  end
end
