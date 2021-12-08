defmodule CockpitWeb.Helpers do
  @moduledoc """
  Generic helper functions for API application.
  """

  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [render: 3, put_view: 2]

  alias CockpitWeb.ErrorView

  def fragment_changeset(true, changeset), do: {:valid, changeset.changes}
  def fragment_changeset(false, changeset), do: {:invalid, fragment_error_changeset(changeset)}

  def fragment_error_changeset(changeset, title \\ "Malformed request") do
    errors =
      changeset
      |> changeset_traverse_errors()
      |> format_errors()

    %{title: title, errors: errors}
  end

  defp changeset_traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp format_errors(errors) do
    Enum.reduce(errors, %{}, fn {k, v}, acc ->
      Map.merge(acc, %{"#{k}" => hd(v)})
    end)
  end

  def render_error(conn, code, type, errors) do
    conn
    |> put_status(code)
    |> put_view(ErrorView)
    |> render(type, errors)
  end
end
