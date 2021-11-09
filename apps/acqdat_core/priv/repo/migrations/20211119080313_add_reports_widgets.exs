defmodule AcqdatCore.Repo.Migrations.AddReportsWidgets do
  use Ecto.Migration

  def change do
    create table(:acqdat_reports_widgets) do
      add(:label, :string, null: false)
      # add(:slug, :string, null: false)
      add(:uuid, :string, null: false)
      add(:visual_properties, :map)
      add(:source_app, :string)
      add(:source_metadata, :map)
      add(:filter_metadata, :map)
      add(:widget_settings, :map)
      add(:series_data, {:array, :map})
      add(:widget_id, references(:acqdat_widgets), null: false)
      # acqdat_widgets
      add(
        :template_instance_id,
        references(:acqdat_reports_template_instances, on_delete: :delete_all)
      )

      # acqdat_reports_template_instances
      # add :parent_organization_id, references(:organizations, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end

    create(unique_index(:acqdat_reports_widgets, [:uuid]))
    # create(unique_index(:acqdat_reports_widgets, [:slug]))

    # create(
    #   unique_index(:acqdat_reports_widgets, [:template_instance_id, :label],
    #     name: :unique_widget_name_per_report
    #   )
    # )
  end
end
