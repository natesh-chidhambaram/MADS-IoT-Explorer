defmodule AcqdatApiWeb.DashboardManagement.SubpanelController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DashboardManagement.Subpanel
  alias AcqdatApi.DashboardManagement.Subpanel
  alias AcqdatApiWeb.DashboardManagement.SubpanelErrorHelper

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadSubpanel when action in [:update, :delete]

  def create(conn, params) do
    with nil <- conn.status,
         changeset <- verify_create_params(params),
         {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, subpanel}} <- {:create, Subpanel.create(data)} do
      conn
      |> put_status(200)
      |> render("subpanel.json", %{subpanel: subpanel})
    else
      401 -> send_error(conn, 404, SubpanelErrorHelper.error_message(:resource_not_found))
      404 -> send_error(conn, 401, SubpanelErrorHelper.error_message(:unauthorized))
      {:extract, {:error, error}} -> send_error(conn, 400, error)
      {:create, {:error, message}} -> send_error(conn, 400, message.error)
    end
  end

  # TODO: We need to return this pannel with widgets
  def show(conn, %{"id" => uuid}) do
    with nil <- conn.status,
         {:ok, subpanel} <- Subpanel.get_with_widgets(uuid) do
      conn
      |> put_status(200)
      |> render("show.json", %{subpanel: subpanel})
    else
      404 ->
        send_error(conn, 404, SubpanelErrorHelper.error_message(:resource_not_found))

      401 ->
        send_error(conn, 401, SubpanelErrorHelper.error_message(:unauthorized))

      {:error, reason} ->
        send_error(conn, 400, SubpanelErrorHelper.error_message(:not_found, reason))
    end
  end

  # TODO: We need to return this pannel with widgets
  def index(conn, params) do
    with nil <- conn.status,
         changeset <- verify_index_params(params),
         {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:ok, subpanels} <- Subpanel.get_all_with_widgets(data) do
      conn
      |> put_status(200)
      |> render("index.json", %{subpanels: subpanels})
    else
      404 ->
        send_error(conn, 404, SubpanelErrorHelper.error_message(:resource_not_found))

      401 ->
        send_error(conn, 401, SubpanelErrorHelper.error_message(:unauthorized))

      {:error, reason} ->
        send_error(conn, 400, SubpanelErrorHelper.error_message(:not_found, reason))
    end
  end

  def update(conn, params) do
    with nil <- conn.status,
         {:ok, subpanel} <- Subpanel.update(conn.assigns.subpanel, params) do
      conn
      |> put_status(200)
      |> render("subpanel.json", %{subpanel: subpanel})
    else
      {:error, subpanel} ->
        reason =
          case String.valid?(subpanel) do
            false -> extract_changeset_error(subpanel)
            true -> subpanel
          end

        send_error(conn, 400, reason)

      404 ->
        send_error(conn, 404, SubpanelErrorHelper.error_message(:resource_not_found))

      401 ->
        send_error(conn, 401, SubpanelErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    with nil <- conn.status,
         {:ok, subpanel} <- Subpanel.delete(conn.assigns.subpanel) do
      conn
      |> put_status(200)
      |> render("subpanel.json", %{subpanel: subpanel})
    else
      401 ->
        send_error(conn, 401, SubpanelErrorHelper.error_message(:unauthorized))

      404 ->
        send_error(conn, 404, SubpanelErrorHelper.error_message(:resource_not_found))

      {:error, reason} ->
        send_error(conn, 400, reason)

      {:error, %Ecto.Changeset{} = changeset} ->
        error = extract_changeset_error(changeset)
        send_error(conn, 400, error)
    end
  end
end
