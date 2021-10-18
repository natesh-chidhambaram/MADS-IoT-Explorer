defmodule AcqdatCore.EntityManagement.Schema.Grouping do
  use AcqdatCore.Schema
  alias AcqdatCore.AlertMessage.Token

  @callback run_check?(map, Token) :: boolean()
  @callback settings() :: map
  @callback name() :: String.t()

  @primary_key false
  embedded_schema do
    field(:module, EntityAlertGroupingEnum)
    field(:grouping_parameters, :map)
  end

  @parameters ~w(module grouping_parameters)a

  def changeset(%__MODULE__{} = grouping, params) do
    grouping
    |> cast(params, @parameters)
    |> validate_embedded()
  end

  defp validate_embedded(%Ecto.Changeset{} = changeset) do
    validate_embedded_data(changeset, :module, :grouping_parameters)
  end

  def alert_groupings() do
  end

  defp validate_embedded_data(%Ecto.Changeset{valid?: true} = changeset, module_key, key) do
    with {:ok, preferences} <- fetch_change(changeset, key),
         {:ok, module_key} <- fetch_change(changeset, module_key) do
      preference_changeset = module_key.changeset(struct(module_key), preferences)
      add_preferences_change(preference_changeset, changeset, key)
    else
      :error ->
        changeset

      {:error, message} ->
        add_error(changeset, module_key, message)
    end
  end

  defp validate_embedded_data(changeset, _module_key, _key), do: changeset

  defp add_preferences_change(%Ecto.Changeset{valid?: true} = embed_changeset, changeset, key) do
    data = embed_changeset.changes
    put_change(changeset, key, data)
  end

  defp add_preferences_change(pref_changeset, changeset, key) do
    additional_info =
      pref_changeset
      |> traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    add_error(changeset, key, "invalid_preferences", additional_info)
  end
end
