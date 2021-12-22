defmodule AcqdatApiWeb.Plug.LoadSubpanel do
  import Plug.Conn
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"subpanel_id" => subpanel_id}} = conn, _params) do
    check_subpanel(conn, subpanel_id)
  end

  def call(%{params: %{"id" => subpanel_id}} = conn, _params) do
    check_subpanel(conn, subpanel_id)
  end

  defp check_subpanel(conn, subpanel_id) do
    with {subpanel_id, _} <- Integer.parse(subpanel_id),
      {:ok, subpanel} <- PanelModel.get_by_id(subpanel_id) do
      assign(conn, :subpanel, subpanel)
    else
      _ -> put_status(conn, 404)
    end
  end
end
