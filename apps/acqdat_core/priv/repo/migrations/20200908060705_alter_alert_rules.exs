defmodule AcqdatCore.Repo.Migrations.AlterAlertRules do
  use Ecto.Migration

  def change do
    alter table(:acqdat_alert_rules) do
      add(:phone_numbers, {:array, :string})
    end
  end
end
