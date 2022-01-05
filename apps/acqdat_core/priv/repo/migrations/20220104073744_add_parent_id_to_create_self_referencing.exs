defmodule AcqdatCore.Repo.Migrations.AddParentIdToCreateSelfReferencing do
  use Ecto.Migration

  def change do
    alter table("acqdat_panel") do
      add :parent_id, :integer, default: -1
    end

    drop_if_exists unique_index("acqdat_panel", [:dashboard_id, :name], name: :unique_panel_name_per_dashboard)
    create unique_index("acqdat_panel", [:dashboard_id, :name, :parent_id], name: :unique_panel_name_per_dashboard)
  end
end
