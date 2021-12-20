defmodule AcqdatApiWeb.Plug.LoadSubpanel do
  import Plug.Conn
  alias AcqdatCore.Model.DashboardManagement.Subpanel, as: SubpanelModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"subpanel_id" => subpanel_uuid}} = conn, _params) do
    check_subpanel(conn, subpanel_uuid)
  end

  def call(%{params: %{"id" => subpanel_uuid}} = conn, _params) do
    check_subpanel(conn, subpanel_uuid)
  end

  defp check_subpanel(conn, subpanel_uuid) do
    subpanel_uuid
    |> SubpanelModel.get_by_uuid()
    |> case do
      {:ok, subpanel} -> assign(conn, :subpanel, subpanel)
      {:error, _message} -> put_status(conn, 404)
    end
  end
end
