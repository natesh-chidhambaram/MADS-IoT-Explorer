defmodule AcqdatApiWeb.Plug.LoadTemplateInstance do
  import Plug.Conn
  alias AcqdatCore.Reports.Model.TemplateInstance, as: TemplateInstanceModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"template_instance_id" => template_instance_id}} = conn, _params) do
    check_template_instance(conn, template_instance_id)
  end

  def call(%{params: %{"id" => template_instance_id}} = conn, _params) do
    check_template_instance(conn, template_instance_id)
  end

  defp check_template_instance(conn, template_instance_id) do
    case Integer.parse(template_instance_id) do
      {template_instance_id, _} ->
        case TemplateInstanceModel.get_by_id(template_instance_id) do
          {:ok, template_instance} ->
            assign(conn, :template_instance, template_instance)

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
