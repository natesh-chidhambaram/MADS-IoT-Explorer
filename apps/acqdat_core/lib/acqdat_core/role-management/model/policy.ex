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
    Enum.reduce(actions, [], fn action, acc ->
      query =
        from(policy in Policy,
          where:
            policy.action == ^action["action"] and policy.feature == ^action["feature"] and
              policy.app == ^action["app"],
          select: policy.id
        )

      acc ++ Repo.all(query)
    end)
  end
end
