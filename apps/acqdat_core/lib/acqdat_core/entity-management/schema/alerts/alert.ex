defmodule AcqdatCore.Schema.EntityManagement.Alert do
  use AcqdatCore.Schema
  alias AcqdatCore.Alerts.Schema.Grouping
  alias AcqdatCore.EntityManagement.Schema.Alert.Recipient
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Alerts.Schema.AlertEventLog

  @typedoc """
  `name`: A heading for the alert
  `description`: Description of the alert. This is what the user will see.
  `alert_policy_meta`: A map containing all the data due to which the alert was
    raised, it should be a map containing all the information. The alert policy meta
    should be a consistent meta and shouldn't change a lot as it used for grouping
    the alerts together.
  `grouping_meta`: Data related to grouping of the alerts raised from this particular
    policy.
  `grouping_hash`: The grouping hash is created from the combination of
    `alert_policy_meta`, `entity_name`, `entity_uuid`, `org_uuid` and `project_uuid`.
    It's used for uniquely idenitifying an alert and group similar events together.
  `entity_name`: Entity for which the alert was raised, this can be optional.
  `entity_id`: uuid for the entity.
  `communicaton_medium`: Communication medium which should be used for sending the
    alert. It can be `email`, `sms` or `in-app`.
  `recipient_ids`: Ids of the users who should be notified using the communication
    mediums.
  `severity`: Severity of the alert. Severity can be `high`, `low` or `medium`
  `status`: A flag to show if the alert is resolved.
  `app`: Shows which app raised the alert.
  `org_id`: id of the organisation for which the alert was raised.
  `project_id`: id of the project for which alert happened. This is optional.
  `alert_events_log`: Holds all the data alongwith timestamp about the alert
    event.
  `alert_meta`: Holds metadata related to the alert.
  ``
  """

  @type t :: %__MODULE__{}

  schema "acqdat_alerts" do
    ## Fields from the token sent by an app.
    field(:name, :string, null: false)
    field(:description, :string)
    field(:alert_policy_meta, :map)
    field(:entity_name, :string)
    field(:entity_id, :integer)
    field(:communication_medium, {:array, :string})
    field(:severity, EntityAlertSeverityEnum)
    field(:app, EntityAppEnum)
    field(:project_id, :integer)

    ## Fields that would be generated later on.
    field(:grouping_hash, :string)
    field(:status, EntityAlertStatusEnum)
    field(:alert_meta, :map)

    ## Embeds
    embeds_one(:grouping_meta, Grouping, on_replace: :update)
    embeds_many(:recipient_ids, Recipient)

    ## associations
    belongs_to(:org, Organisation, on_replace: :delete)
    has_many(:alert_event_log, AlertEventLog)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name app communication_medium
    severity status org_id)a
  @optional_params ~w(alert_policy_meta description entity_name entity_id project_id
    grouping_hash alert_meta)a
  @permitted_params @required_params ++ @optional_params

  @comm_medium ~w(e-mail in-app sms)s

  def changeset(%__MODULE__{} = alert, params) do
    alert
    |> cast(params, @permitted_params)
    |> cast_embed(:recipient_ids)
    |> cast_embed(:grouping_meta, with: &Grouping.changeset/2)
    |> validate_required(@required_params)
    |> validate_subset(:communication_medium, @comm_medium)
    |> unique_constraint(:grouping_hash,
      name: :unique_grouping_hash_per_alert,
      message: "unqiue hash per alert should be generated"
    )
    |> assoc_constraint(:org)
  end

  @update_parameters ~w(name description
    communication_medium status severity alert_meta)a

  def update_changeset(%__MODULE__{} = alert, params) do
    alert
    |> cast(params, @update_parameters)
    |> cast_embed(:grouping_meta, with: &Grouping.changeset/2)
    |> cast_embed(:recipient_ids)
    |> validate_subset(:communication_medium, @comm_medium)
  end
end

defmodule AcqdatCore.EntityManagement.Schema.Alert.Recipient do
  use AcqdatCore.Schema

  # TODO: There should be a field to store communication related info such as email
  #      of the user, or phone number to which the alert shold be sent

  @primary_key false
  embedded_schema do
    field(:type, :string)
    field(:id, :integer)
  end

  @params ~w(type id)a

  def changeset(%__MODULE__{} = recipient, params) do
    recipient
    |> cast(params, @params)
    |> validate_required(@params)
  end
end
