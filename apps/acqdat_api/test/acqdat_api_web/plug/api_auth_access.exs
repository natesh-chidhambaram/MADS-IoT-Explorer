defmodule AcqdatApiWeb.ApiAccessAuthTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.{Policy, Group}

  describe "checkin api access to users/2" do
    setup :setup_conn
    setup :setup_groups_and_policies

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
    policy1 = %{
      name: "policy_1",
      org_id: org.id,
      actions: [
        %{app: "EntityManagement", feature: "Project", action: "delete"},
        %{app: "EntityManagement", feature: "Sensor", action: "create"}
      ]
    }

    {:ok, policy1} = Policy.create(policy1)

    group1 = %{
      name: "group_1",
      org_id: org.id,
      user_ids: [user.id],
      policy_ids: [policy1.id]
    }

    {:ok, group1} = Group.create(group1)
    [policy: policy1, group: group1]
  end
end
