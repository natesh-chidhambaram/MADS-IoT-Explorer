defmodule AcqdatApiWeb.Plug.LoadPanel do
  import Plug.Conn
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"panel_id" => panel_id}} = conn, _params) do
    check_panel(conn, panel_id)
  end

  def call(%{params: %{"id" => panel_id}} = conn, _params) do
    check_panel(conn, panel_id)
  end

  defp check_panel(conn, panel_id) do
    panel_id =
      case is_integer(panel_id) do
        true ->
          panel_id

        false ->
          {panel_id, _} = Integer.parse(panel_id)
          panel_id
      end

    case PanelModel.get_by_id(panel_id) do
      {:ok, panel} ->
        assign(conn, :panel, panel)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
