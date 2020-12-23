defmodule AcqdatApiWeb.ApiAccess.UserGroupView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.ApiAccess.UserGroupView

  def render("user_group.json", %{group: group}) do
    %{
      id: group.id,
      name: group.name,
      org_id: group.org_id,
      policies: render_many(group.policies, UserGroupView, "policies.json")
    }
  end

  def render("policies.json", %{user_group: user_group}) do
    %{
      action: user_group.action,
      app: user_group.app,
      feature: user_group.feature
    }
  end
end
