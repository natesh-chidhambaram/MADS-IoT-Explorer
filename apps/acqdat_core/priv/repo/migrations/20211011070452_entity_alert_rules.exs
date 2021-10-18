defmodule AcqdatCore.Repo.Migrations.EntityAlertRules do
  use Ecto.Migration

  def change do
    create table(:entity_alert_rules) do
      add(:grouping_meta, :map)
      add(:phone_numbers, {:array, :string})
      add :rule_name, :string
      add :uuid, :string, null: false
      add :slug, :string, null: false
      add :app, EntityAppEnum.type(), null: false
      add :partials, {:array, :map}, null: false
      add :communication_medium, {:array, :string}
      add :recepient_ids, {:array, :integer}
      add :assignee_ids, {:array, :integer}
      add :expression, :string
      add :severity, EntityAlertSeverityEnum.type(), null: false
      add :status, EntityAlertRulesStatusEnum.type(), null: false
      add :creator_id, :integer, null: false
      add :project_id, :integer
      add :org_id, :integer, null: false
      add :description, :text
      timestamps(type: :timestamptz)
    end
  end
end
