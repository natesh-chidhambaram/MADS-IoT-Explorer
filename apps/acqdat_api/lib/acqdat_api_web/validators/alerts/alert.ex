defmodule AcqdatApiWeb.Validators.Alerts.Alert do
  @moduledoc """
  All the alert parameters being sent from the api's will be first verified here so that later stages errors can be avoided on the intial level
  """
  use Params

  @doc """
  required_params:- name policy_name policy_module_name app entity_name entity_id communication_medium recepient_ids severity status creator_id org_id
  optional_params:- description assignee_ids project_id
  """

  defparams(
    verify_alert(%{
      name!: :string,
      entity_id!: :integer,
      policy_name!: :string,
      entity_name!: :string,
      policy_module_name!: :string,
      communication_medium!: {:array, :string},
      rule_parameters!: {:array, :map},
      recepient_ids!: {:array, :integer},
      assignee_ids: {:array, :integer},
      severity!: :string,
      status!: :string,
      app!: :string,
      project_id: :integer,
      creator_id!: :integer,
      description: :string,
      org_id!: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer
    })
  )
end
