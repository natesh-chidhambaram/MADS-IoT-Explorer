defmodule AcqdatCore.Alerts.Model.AlertRules do
  @moduledoc """
  Contains CREATE, UPDATE, DELETE, GET and INDEX model functions
  """
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Alerts.Schema.AlertRules
  alias AcqdatCore.Model.RoleManagement.User

  @doc """
    create function will prepare the changeset and just insert it into the database
  """
  def create(params) do
    changeset = AlertRules.changeset(%AlertRules{}, params)
    Repo.insert(changeset)
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

  @doc """
  Check the existence of alert rule for a particular entity provided it's ID.
  """
  def check_rule(entity_id, entity) do
    query =
      from(rule in AlertRules,
        where: rule.entity == ^entity and rule.entity_id == ^entity_id and rule.status == ^:enable
      )

    List.first(Repo.all(query))
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    AlertRules |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  @doc """
  For extracting recipient emails
  """

  def send_alert(alert) do
    Enum.reduce(alert.recepient_ids, [], fn recipient, acc ->
      if recipient != 0 do
        user = User.extract_email(recipient)
        acc ++ [user]
      else
        acc
      end
    end)
  end
end
