defmodule AcqdatApiWeb.IotManager.DataController do
  use AcqdatApiWeb, :authorized_controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.IotManager.Data
  alias AcqdatApi.IotManager.Data
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatApiWeb.IotManager.DataErrorHelper
  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadGateway when action in [:gateway_data, :gateway_data_delete]

  def gateway_data(conn, params) do
    changeset = verify_gateway_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, gateway_data} = {:list, Data.get_all_gateway_data(data)}

        conn
        |> put_status(200)
        |> render("gateway_index.json", gateway_data)

      404 ->
        conn
        |> send_error(404, DataErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DataErrorHelper.error_message(:unauthorized))
    end
  end

  def gateway_data_delete(conn, params) do
    case conn.status do
      nil ->
        # Data.get_all_sensors_data(data)}
        asd = Data.delete_data(:sensors_data, params)

      # conn
      # |> put_status(200)
      # |> render("sensor_index.json", sensors_data)

      404 ->
        conn
        |> send_error(404, DataErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DataErrorHelper.error_message(:unauthorized))
    end
  end
end
