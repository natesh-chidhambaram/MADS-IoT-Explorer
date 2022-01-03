defmodule AcqdatCore.Repo.Migrations.CreateShareResources do
  use Ecto.Migration

  def change do
    create table(:acqdat_share_resources) do
      add(:type, :integer, null: false)
      add(:resource_id, :integer, null: false)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)

      add(:org_id, references("acqdat_organisation"), null: false)
      add(:share_by_id, references("users"), null: false)
      add(:cockpit_user_id, references("cockpit_users"), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_share_resources", [:type, :resource_id, :cockpit_user_id])
  end
end
