defmodule AcqdatCore.Repo.Migrations.ChangePanelTableToSelfReferecing do
  use Ecto.Migration

  def change do
    alter table("acqdat_panel") do
      add :parent_id, references(:acqdat_panel)
    end
  end
end
