defmodule AcqdatCore.Model.RoleManagement.Policy do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.RoleManagement.Policy
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Policy.changeset(%Policy{}, params)
    Repo.insert(changeset)
  end

  def extract_policies(actions) do
    params =
      Enum.reduce(actions, %{}, fn action, acc ->
        query =
          from(policy in Policy,
            where:
              policy.action == ^action["action"] and policy.feature == ^action["feature"] and
                policy.app == ^action["app"],
            select: policy.id
          )

        case Map.has_key?(acc, :query) do
          true ->
            query = Ecto.Query.union(acc.query, ^query)
            Map.replace!(acc, :query, query)

          false ->
            Map.put_new(acc, :query, query)
        end
      end)

    case Map.has_key?(params, :query) do
      true -> Repo.all(params.query)
      false -> []
    end
  end
end
