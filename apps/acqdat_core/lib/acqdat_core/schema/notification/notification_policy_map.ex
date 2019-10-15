defmodule AcqdatCore.Notification.PolicyMap do
  @moduledoc """
  Holds a mapping between policy module and an integer representation
  to be used for storing in database.

  The module also exposes other important helpers related to notification
  policy modules.

  ### Caution !
  The module name can be modified however, the integer representation
  should not be changed as it will lead to incosistent state in the
  database.
  """

  @module_policy_map %{
    "Elixir.AcqdatCore.Schema.Notification.RangeBased" => 0
  }
  @error "module not found"

  def load(param) do
    @module_policy_map
    |> Enum.find(fn {key, value} ->
      value == param or key == param
    end)
    |> case do
      nil ->
        {:error, @error}

      {module, _value} ->
        {:ok, String.to_existing_atom(module)}
    end
  end

  def dump(param) do
    case Map.get(@module_policy_map, param) do
      nil ->
        {:error, "module not found"}

      module ->
        {:ok, module}
    end
  end

  @doc """
  Returns the list of policies availble for configuring notification.
  """
  def policies() do
    Map.keys(@module_policy_map)
  end
end
