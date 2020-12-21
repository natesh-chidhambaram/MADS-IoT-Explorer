defmodule AcqdatApiWeb.ApiAccessAuthTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.{Policy, Group, UserPolicy}

  describe "checkin api access to users/2" do
    setup :setup_conn
    setup :setup_groups_and_policies
    @tag timeout: :infinity

    test "checking if user is allowed to access an api", %{conn: conn, org: org, user: user} do
      project = build(:project)

      data = %{
        name: project.name,
        creator_id: user.id
      }

      conn = post(conn, Routes.project_path(conn, :create, org.id), data)
      require IEx
      IEx.pry()
    end
  end

  def setup_groups_and_policies(%{org: org, user: user}) do
    policy1 = %{app: "EntityManagement", feature: "Project", action: "create"}

    policy2 = %{
      name: "policy_2",
      org_id: org.id,
      actions: [
        %{app: "EntityManagement", feature: "Asset", action: "delete"},
        %{app: "EntityManagement", feature: "Sensor", action: "create"}
      ]
    }

    {:ok, policy1} = Policy.create(policy1)
    {:ok, policy2} = Policy.create(policy2)

    group1 = %{
      name: "group_1",
      org_id: org.id,
      user_ids: [user.id],
      policy_ids: [policy1.id]
    }

    user_group = %{
      user_id: user.id,
      policy_id: policy2.id
    }

    {:ok, group1} = Group.create(group1)
    {:ok, user_policy} = UserPolicy.create(user_group)
    [policies: [policy1, policy2], group: group1, user_policy: [user_policy]]
  end
end
