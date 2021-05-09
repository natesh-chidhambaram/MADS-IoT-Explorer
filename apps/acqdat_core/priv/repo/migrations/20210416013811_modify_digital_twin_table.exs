defmodule AcqdatCore.Repo.Migrations.ModifyDigitalTwinTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_digital_twins") do
      add(:description, :string)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:settings, :map)
      add(:opened_on, :utc_datetime)
      add(:creator_id, references(:users, on_delete: :delete_all))
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
    end

    create unique_index("acqdat_digital_twins", [:slug])
    create unique_index("acqdat_digital_twins", [:uuid])
    create unique_index("acqdat_digital_twins", [:org_id, :project_id, :name], name: :unique_dashboard_name_per_project_for_one_org)
  end
end
