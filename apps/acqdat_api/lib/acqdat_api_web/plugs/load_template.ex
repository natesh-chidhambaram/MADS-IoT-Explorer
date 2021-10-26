defmodule AcqdatApiWeb.Plug.LoadTemplate do
  import Plug.Conn
  alias AcqdatCore.Reports.Model.Template, as: TemplateModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"template_id" => template_id}} = conn, _params) do
    check_template(conn, template_id)
  end

  def call(%{params: %{"id" => template_id}} = conn, _params) do
    check_template(conn, template_id)
  end

  defp check_template(conn, template_id) do
    case Integer.parse(template_id) do
      {template_id, _} ->
        case TemplateModel.get_by_id(template_id) do
          {:ok, template} ->
            assign(conn, :template, template)

          {:error, _message} ->
            conn
            |> put_status(404)
        end

      :error ->
        conn
        |> put_status(404)
    end
  end
end
