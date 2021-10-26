defmodule AcqdatCore.Schema.EntityManagement.AlertRules do
  @moduledoc """
  AlertRules are the rules which an entity follows before creating alerts.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.EntityManagement.Schema.AlertRulesGrouping
  alias AcqdatCore.EntityManagement.Schema.Partials
  alias AcqdatCore.Schema.EntityManagement.Entities

  @typedoc """
  `entity`: entity name for which this alert rule is defined example: "sensor", "gateway"
  `entity_id`:  "id" for that entity
  `policy_name`:  policy name which this alert rule follow like "RangeBased"
  `entity_parameters`: will hold parameters of that entity for which this alert rule is applicable
  `rule_parameters`: rule parameters will hold the parameters with their values that is required for that policy to work on.
  `policy_type`: policy type can be of two type user level or project level
  `description`: description of this alert rule
  `project`:  project id this alert rule is related to.
  `creator`: creator is the one which is creating this alert rule for the following project, this will be used for adding filter on who can create alert rule.
  `recepient_ids`: Once a alert is generated using this alert rule all those recepients will get the notification of the alert
  `assignee_ids`: The generated alert will be assigned to the assigniee ids
  `severity`: The severity of that alert
  `status`: The status wheather that alert is resolved or not.
  """

  @type t :: %__MODULE__{}

  schema "entity_alert_rules" do
    field(:rule_name, :string)
    embeds_many(:partials, Partials)
    field(:entity, EntityEnum, null: false)
    field(:entity_id, :integer, null: false)

    embeds_one(:grouping_meta, AlertRulesGrouping, on_replace: :update)

    field(:uuid, :string, null: false)
    field(:communication_medium, {:array, :string})
    field(:slug, :string, null: false)
    field(:expression, :string, null: false)
    field(:recepient_ids, {:array, :integer})
    field(:phone_numbers, {:array, :string})
    field(:assignee_ids, {:array, :integer})
    field(:severity, AlertSeverityEnum)
    field(:status, AlertRulesStatusEnum)
    field(:app, AppEnum)

    field(:description, :string)

    # Associations
    field(:creator_id, :integer)
    field(:project_id, :integer)
    field(:org_id, :integer)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(rule_name app expression communication_medium recepient_ids status uuid entity entity_id slug creator_id org_id severity)a
  @optional_params ~w(phone_numbers description project_id assignee_ids)a
  @permitted_params @required_params ++ @optional_params

  def changeset(%__MODULE__{} = alert_rule, params) do
    alert_rule
    |> cast(params, @permitted_params)
    |> cast_embed(:grouping_meta, with: &AlertRulesGrouping.changeset/2)
    |> cast_embed(:partials, with: &Partials.changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> unique_constraint(:slug, name: :acqdat_alert_rules_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_alert_rules_uuid_index)
  end
end
