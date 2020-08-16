defmodule AcqdatCore.Repo.Migrations.AcqdatAlertRules do
  use Ecto.Migration

  #alert rule are the set of rules that are being defined on for a particular entity parameter
  def change do
    create table(:acqdat_alert_rules) do
      add :rule_name, :string
      add :entity, :string, null: false
      add :entity_id, :integer, null: false
      add :uuid, :string, null: false
      add :slug, :string, null: false
      add :app, AppEnum.type(), null: false
      add :policy_name, PolicyDefinitionModuleEnum.type(), null: false
      add :rule_parameters, :map, null: false
      add :entity_parameters, :map, null: false
      add :communication_medium, {:array, :string}
      add :recepient_ids, {:array, :integer}
      add :assignee_ids, {:array, :integer}
      add :severity, AlertSeverityEnum.type(), null: false
      add :status, AlertRulesStatusEnum.type(), null: false
      add :creator_id, :integer, null: false
      add :project_id, :integer
      add :org_id, :integer, null: false
      add :policy_type, {:array, :string}
      add :description, :text

      timestamps(type: :timestamptz)
    end

    create index(:acqdat_alert_rules, [:entity_id])
    create unique_index(:acqdat_alert_rules, [:uuid])
    create unique_index(:acqdat_alert_rules, [:slug])
  end
end
