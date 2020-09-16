defmodule AcqdatCore.Repo.Migrations.AcqdatAlterAlertRules do
  use Ecto.Migration

  def change do
    alter table(:acqdat_alert_rules) do
      add(:rate_limit, :integer)
      add(:rate_limit_time, :utc_datetime)
    end
  end
end
