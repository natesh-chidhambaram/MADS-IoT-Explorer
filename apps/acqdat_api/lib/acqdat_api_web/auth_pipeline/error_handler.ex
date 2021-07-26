defmodule AcqdatApiWeb.ErrorHandler do
  use AcqdatApiWeb, :controller

  def auth_error(conn, {type, _}, _) do
    conn
    |> put_status(403)
    |> put_view(AcqdatApiWeb.ErrorView)
    |> render("403.json", message: to_string(type))
  end
end
