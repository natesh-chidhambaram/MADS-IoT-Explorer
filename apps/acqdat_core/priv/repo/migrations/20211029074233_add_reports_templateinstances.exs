defmodule AcqdatCore.Repo.Migrations.AddReportsTemplateinstances do
  use Ecto.Migration

    def change do
      create table(:acqdat_reports_template_instances) do
        add(:uuid, :string)
        add(:name, :string)
        add(:type, :string, default: "A4")
        add(:pages, {:array, :map})
        add(:org_id, references(:acqdat_organisation, on_delete: :delete_all))
        add(:created_by_user_id, references(:users, on_delete: :nothing))
      end

      create(index(:acqdat_reports_template_instances, [:org_id]))
      create unique_index(:acqdat_reports_template_instances, [:name, :org_id])

    end
  end
