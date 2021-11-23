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

  @doc """
  update function will update the alert rules
  """
  def update(alert_rules, params) do
    changeset = AlertRules.changeset(alert_rules, params)
    Repo.update(changeset)
  end

  @doc """
  delete function will delete the alert rules
  """
  def delete(alert_rules) do
    Repo.delete(alert_rules)
  end

  @doc """
  for fetching a alert rule from the given ID
  """
  def get_by_id(id) when is_integer(id) do
    case Repo.get(AlertRules, id) do
      nil ->
        {:error, "Alert not found"}

      alert_rules ->
        {:ok, alert_rules}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}) do
    query =
      from(alert_rules in AlertRules,
        where: alert_rules.org_id == ^org_id
      )

    query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def list_policies() do
    Enum.reduce(EntityPolicyDefinitionModuleEnum.__enum_map__(), [], fn {key, value}, acc ->
      acc ++ [key]
    end)
  end
end
