defmodule AcqdatCore.Repo.Migrations.UpdateAlertRules do
  use Ecto.Migration

  def change do
    alter table(:acqdat_alert_rules) do
      add(:grouping_meta, :map)
    end
  end
end
