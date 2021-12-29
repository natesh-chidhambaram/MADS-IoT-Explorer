defmodule AcqdatIotWeb.DataParser.DataDumpController do
  use AcqdatIotWeb, :controller
  alias AcqdatCore.IotManager.Server
  alias AcqdatApiWeb.EntityManagement.AssetErrorHelper
  import AcqdatIoTWeb.Helpers

  plug AcqdatIoTWeb.Plug.LoadProject
  plug AcqdatIoTWeb.Plug.LoadOrg
  plug AcqdatIoTWeb.Plug.LoadGateway

  @doc """
  Adds data recieved from gateway to IoT Storage.
  """
  def create(conn, params) do
    case conn.status do
      nil ->
        params = add_metadata(conn.assigns, params)
        Server.log_data(params)

        conn
        |> put_status(202)
        |> json(%{"data inserted" => true})

      404 ->
        conn
        |> send_error(404, AssetErrorHelper.error_message(:unauthorized))
    end
  end

  ######################## private functions ##########################
  defp add_metadata(assigns, params) do
    %{
      org_uuid: assigns.org.uuid,
      project_uuid: assigns.project.uuid,
      gateway_uuid: assigns.gateway.uuid,
      data: params,
      mode: "http"
    }
  end
end
