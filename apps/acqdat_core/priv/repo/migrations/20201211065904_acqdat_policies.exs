defmodule AcqdatCore.Repo.Migrations.AcqdatPolicies do
  use Ecto.Migration

  def change do
    create table("acqdat_policies") do
      add(:name, :string, null: false)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:actions, {:array, :map})

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_policies", [:name, :org_id])
  end
end
