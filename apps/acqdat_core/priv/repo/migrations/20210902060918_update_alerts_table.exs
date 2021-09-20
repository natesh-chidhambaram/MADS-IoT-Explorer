defmodule AcqdatCore.Repo.Migrations.UpdateAlertsTable do
  use Ecto.Migration

  def up do
    drop table("alerts")

    create table("acqdat_alerts") do
      add(:name, :string)
      add(:description, :text)
      add(:alert_policy_meta, :map)
      add(:grouping_meta, :map)
      add(:entity_name, :string)
      add(:entity_id, :integer)
      add(:communication_medium, {:array, :string})
      add(:recipient_ids, {:array, :map})
      add(:severity, AlertSeverityEnum.type(), null: false)
      add(:status, AlertStatusEnum.type(), null: false)
      add(:app, AppEnum.type(), null: false)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:project_id, :integer)
      add(:grouping_hash, :string)
      add(:alert_meta, :map)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_alerts", [:grouping_hash],
      name: :unique_grouping_hash_per_alert)

    create table("acqdat_alert_event_log") do
      add(:inserted_timestamp, :timestamptz)
      add(:name, :string)
      add(:description, :string)
      add(:alert_metadata, :map)
      add(:severity, AlertSeverityEnum.type())
      add(:alert_id, references("acqdat_alerts", on_delete: :delete_all), null: false)
    end
  end

  def down do
    drop table("acqdat_alert_event_log")
    unique_index("acqdat_alerts", [:grouping_hash],
      name: :unique_grouping_hash_per_alert)
    drop table("acqdat_alerts")

    create table(:alerts) do
      add :name, :string
      add :description, :text
      add :policy_name, PolicyDefinitionEnum.type(), null: false
      add :policy_module_name, PolicyDefinitionModuleEnum.type(), null: false
      add :app, AppEnum.type(), null: false
      add :entity_name, :string
      add :entity_id, :integer
      add :rule_parameters, {:array, :map}
      add :communication_medium, {:array, :string}
      add :recepient_ids, {:array, :integer}
      add :assignee_ids, {:array, :integer}
      add :severity, AlertSeverityEnum.type(), null: false
      add :status, AlertStatusEnum.type(), null: false
      add :creator_id, :integer, null: false
      add :project_id, :integer
      add :org_id, :integer, null: false

      timestamps(type: :timestamptz)
    end
  end
end
