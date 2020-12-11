defmodule AcqdatApiWeb.RoleManagement.ExtractedRoutesView do
  use AcqdatApiWeb, :view

  def render("index.json", %{routes: routes}) do
    %{
      routes: routes
    }
  end
end
