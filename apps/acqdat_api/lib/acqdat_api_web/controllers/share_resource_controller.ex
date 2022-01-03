defmodule AcqdatApiWeb.ShareResourceController do
  use AcqdatApiWeb, :controller

  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.ShareResource

  alias AcqdatApi.ResourceManagement.ShareResource

  def share(conn, params) do
    with changeset <- validate_resource_sharing_data(params),
         {:ok, data} <- extract_changeset_data(changeset),
         {:ok, :shared} <- ShareResource.share(data, conn.assigns.current_user.id) do
      json(conn, %{status: :success})
    else
      {:error, errors} ->
        conn
        |> put_status(404)
        |> render("error.json", errors: errors)
    end
  end
end
