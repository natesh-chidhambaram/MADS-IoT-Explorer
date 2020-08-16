defmodule AcqdatCore.Alerts.Schema.Alert do
  use AcqdatCore.Schema

  schema "alerts" do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:policy_name, PolicyDefinitionEnum)
    field(:policy_module_name, PolicyDefinitionModuleEnum)
    field(:app, AppEnum)
    field(:entity_name, :string)
    field(:entity_id, :integer)
    field(:communication_medium, {:array, :string})
    field(:recepient_ids, {:array, :integer})
    field(:assignee_ids, {:array, :integer})
    field(:severity, AlertSeverityEnum)
    field(:status, AlertStatusEnum)
    field(:creator_id, :integer)
    field(:project_id, :integer)
    field(:org_id, :integer)

    embeds_many :rule_parameters, RuleParameters, on_replace: :delete do
      field(:name, :string, null: false)
      field(:data_type, :string, null: false)
      field(:entity_parameter_uuid, :string, null: false)
      field(:entity_parameter_name, :string, null: false)
      field(:value, :integer, null: false)
    end

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name policy_name policy_module_name app entity_name entity_id communication_medium recepient_ids severity status creator_id org_id)a
  @optional_params ~w(description assignee_ids project_id)a
  @embedded_rule_parameters_required ~w(name data_type entity_parameter_uuid entity_parameter_name value)a
  @permitted_rule_parameters @embedded_rule_parameters_required
  @permitted_params @required_params ++ @optional_params

  def changeset(alert, params) do
    alert
    |> cast(params, @permitted_params)
    |> cast_embed(:rule_parameters, with: &rule_parameters_changeset/2)
    |> validate_required(@required_params)
  end

  defp rule_parameters_changeset(schema, params) do
    schema
    |> cast(params, @permitted_rule_parameters)
    |> validate_required(@embedded_rule_parameters_required)
  end
end
