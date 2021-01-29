defmodule AcqdatApiWeb.RoleManagement.ExtractedRoutesController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.ExtractRoutes
  import AcqdatApiWeb.Helpers

  def apis(conn, _params) do
    case conn.status do
      nil ->
        {:list, routes} = {:list, ExtractRoutes.extract_routes()}

        conn
        |> put_status(200)
        |> render("index.json", %{routes: routes})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
