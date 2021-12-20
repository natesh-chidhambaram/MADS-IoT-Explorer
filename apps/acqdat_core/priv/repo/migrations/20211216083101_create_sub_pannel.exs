defmodule AcqdatCore.Repo.Migrations.CreateSubPannel do
  use Ecto.Migration

  def change do
    create table(:acqdat_subpanel, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :settings, :map
      add :widget_layouts, :map
      add :filter_metadata, :map
      add :icon, :string, default: "home"
      add :panel_id, references("acqdat_panel", on_delete: :delete_all), null: false
      add :dashboard_id, references("acqdat_dashboard", on_delete: :delete_all), null: false
      add :org_id, references("acqdat_organisation", on_delete: :delete_all), null: false

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_subpanel", [:panel_id, :name], name: :unique_subpanel_name_per_pannel)
  end
end
