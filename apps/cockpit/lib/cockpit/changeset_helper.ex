defmodule Cockpit.ChangesetHelper do
  @moduledoc """
  Generic helper functions for API application.
  """

  def fragment_changeset(true, changeset), do: {:valid, changeset.changes}
  def fragment_changeset(false, changeset), do: {:error, fragment_error_changeset(changeset)}

  defp fragment_error_changeset(changeset) do
    %{
      title: "Malformed request",
      errors: changeset_traverse_errors(changeset)
    }
  end

  defp changeset_traverse_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
