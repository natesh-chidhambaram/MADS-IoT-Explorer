defmodule AcqdatCore.AlertMessage.Token do
  @enforce_keys [
    :name,
    :description,
    :alert_policy_meta,
    :alert_log,
    :communication_medium,
    :recipient_ids,
    :severity,
    :app,
    :org_id,
    :grouping_meta,
    :inserted_timestamp
  ]

  defstruct [
    :name,
    :description,
    :alert_log,
    :communication_medium,
    :recipient_ids,
    :severity,
    :app,
    :org_id,
    :project_id,
    :grouping_meta,
    :alert_metadata,
    :inserted_timestamp,
    alert_policy_meta: nil,
    entity_name: nil,
    entity_id: nil
  ]
end
