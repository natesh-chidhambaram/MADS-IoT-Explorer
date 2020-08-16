defmodule AcqdatCore.Repo.Migrations.CreateAlerts do
  use Ecto.Migration

  def change do
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
