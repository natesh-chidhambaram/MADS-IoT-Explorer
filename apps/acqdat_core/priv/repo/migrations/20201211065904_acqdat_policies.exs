defmodule AcqdatCore.Repo.Migrations.AcqdatPolicies do
  use Ecto.Migration

  def change do
    create table("acqdat_policies") do
      add(:app, :string, null: false)
      add(:feature, :string, null: false)
      add(:action, :string, null: false)


      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_policies", [:app, :feature, :action])
  end
end
