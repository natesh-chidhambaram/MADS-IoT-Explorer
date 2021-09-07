defmodule Weave.Context do
  defstruct device: %{}, gateway: %{}, project: %{}, tenant: %{}

  @type t :: %__MODULE__{
          device: %{id: String.t()},
          gateway: %{id: String.t()},
          project: %{id: String.t()},
          tenant: %{id: String.t()}
        }
end
