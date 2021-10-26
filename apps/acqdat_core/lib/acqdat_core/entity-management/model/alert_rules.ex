defmodule AcqdatCore.Model.EntityManagement.AlertRules do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.AlertRules
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper

  @doc """
    create function will prepare the changeset and just insert it into the database
  """
  def create(params) do
    changeset = AlertRules.changeset(%AlertRules{}, params)
    Repo.insert(changeset)
  end

  @doc """
  Check the existence of alert rule for a particular entity provided it's ID.
  """
  def check_rule(entity_id, :Sensor) do
    query =
      from(rule in AlertRules,
        where:
          rule.entity == ^:Sensor and rule.entity_id == ^entity_id and rule.status == ^:enable
      )

    Repo.all(query)
  end
end
