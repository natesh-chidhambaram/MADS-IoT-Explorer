defmodule AcqdatApiWeb.Validators.EntityManagement.AlertRules do
  use Params

  defparams(
    verify_alert_rules(%{
      rule_name!: :string,
      expression!: :string,
      partials!: {:array, :map},
      entity!: :integer,
      entity_id!: :integer,
      grouping_meta!: :map,
      uuid: :string,
      communication_medium!: {:array, :string},
      slug: :string,
      recepient_ids!: {:array, :integer},
      assignee_ids!: {:array, :integer},
      severity!: :string,
      phone_numbers: {:array, :string},
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
