defmodule AcqdatCore.Model.EntityManagement.AlertRules do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.AlertRules
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.RoleManagement.User
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

  def send_alert(alert) do
    case Map.has_key?(alert, :recepient_ids) do
      true ->
        Enum.reduce(alert.recepient_ids, [], fn recipient, acc ->
          if recipient != 0 do
            user = User.extract_email(recipient)
            acc ++ [user]
          else
            acc
          end
        end)

      false ->
        Enum.reduce(alert.recipient_ids, [], fn recipient, acc ->
          if recipient != 0 do
            user = User.extract_email(recipient.id)
            acc ++ [user]
          else
            acc
          end
        end)
    end
  end
end
