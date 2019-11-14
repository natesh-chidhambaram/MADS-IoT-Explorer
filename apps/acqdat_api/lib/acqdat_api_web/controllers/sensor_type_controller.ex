defmodule AcqdatApiWeb.SensorTypeController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.SensorType
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.SensorType

  plug AcqdatApiWeb.BearerAuthPipeline
  plug AcqdatApiWeb.EnsureAuthPipeline

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
        conn
        |> json(%{message: message})
    end
  end
end
