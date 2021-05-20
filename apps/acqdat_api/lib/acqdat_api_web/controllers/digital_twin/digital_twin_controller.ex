defmodule AcqdatApiWeb.DigitalTwin.DigitalTwinController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.DigitalTwin.DigitalTwin
  alias AcqdatCore.DigitalTwin.Model.DigitalTwin, as: DigitalTwinModel
  alias AcqdatApiWeb.DigitalTwin.DigitalTwinErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DigitalTwin.DigitalTwin

  plug :load_digital_twin when action in [:update, :delete, :show]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, digital_twin}} = {:list, DigitalTwinModel.get(id)}

        conn
        |> put_status(200)
        |> render("digital_twin.json", digital_twin)

      404 ->
        conn
        |> send_error(404, DigitalTwinErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DigitalTwinErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    opened_on = DateTime.utc_now()
    params = Map.put_new(params, "opened_on", opened_on)

    case conn.status do
      nil ->
        changeset = verify_digital_twin_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, digital_twin}} <- {:create, DigitalTwin.create(data)} do
          conn
          |> put_status(200)
          |> render("digital_twin.json", %{digital_twin: digital_twin})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, DigitalTwinErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DigitalTwinErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{digital_twin: digital_twin}} = conn

        case DigitalTwinModel.update(digital_twin, params) do
          {:ok, digital_twin} ->
            conn
            |> put_status(200)
            |> render("digital_twin.json", %{digital_twin: digital_twin})

          {:error, digital_twin} ->
            error = extract_changeset_error(digital_twin)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, DigitalTwinErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DigitalTwinErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        case DigitalTwinModel.delete(id) do
          {:ok, digital_twin} ->
            conn
            |> put_status(200)
            |> render("digital_twin.json", %{digital_twin: digital_twin})

          {:error, digital_twin} ->
            error = extract_changeset_error(digital_twin)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, DigitalTwinErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DigitalTwinErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, digital_twin} = {:list, DigitalTwinModel.get_all(data, [])}

        conn
        |> put_status(200)
        |> render("index.json", digital_twin)

      404 ->
        conn
        |> send_error(404, DigitalTwinErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DigitalTwinErrorHelper.error_message(:unauthorized))
    end
  end

  defp load_digital_twin(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case DigitalTwinModel.get(id) do
      {:ok, digital_twin} ->
        assign(conn, :digital_twin, digital_twin)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
