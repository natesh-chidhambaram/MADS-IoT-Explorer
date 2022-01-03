defmodule AcqdatApiWeb.ShareResourceView do
  use AcqdatApiWeb, :view

  def render("error.json", %{errors: errors}), do: errors
end
