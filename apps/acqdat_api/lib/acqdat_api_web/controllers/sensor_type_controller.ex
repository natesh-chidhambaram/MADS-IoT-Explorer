defmodule AcqdatApiWeb.SensorTypeController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.SensorType
  alias AcqdatCore.Model.SensorType, as: SensorTypeModel
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.SensorType

  plug :load_sensor_type when action in [:update, :delete]

  def create(conn, params) do
    changeset = verify_sensor_type_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, result}} <- {:create, SensorType.create(data)} do
      conn
      |> put_status(200)
      |> render("sensor_type.json", result)
    else
      {:extract, {:error, error}} ->
        send_error(conn, 400, error)

      {:create, {:error, message}} ->
        send_error(conn, 400, message)
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{sensor_type: sensor_type}} = conn

        case SensorTypeModel.update(sensor_type, params) do
          {:ok, sensor_type} ->
            conn
            |> put_status(200)
            |> render("sensor_type.json", sensor_type)

          {:error, sensor_type} ->
            error = extract_changeset_error(sensor_type)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def load_sensor_type(%{params: %{"id" => id}} = conn, params) do
    {id, _} = Integer.parse(id)

    case SensorTypeModel.get(id) do
      {:ok, sensor_type} ->
        assign(conn, :sensor_type, sensor_type)

      {:error, _message} ->
        conn
        # need to look into this
        |> put_status(404)
    end
  end

  def delete(conn, %{"id" => id} = params) do
    case conn.status do
      nil ->
        case SensorTypeModel.delete(id) do
          {:ok, sensor_type} ->
            conn
            |> put_status(200)
            |> render("sensor_type.json", sensor_type)

          {:error, sensor_type} ->
            error = extract_changeset_error(sensor_type)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
