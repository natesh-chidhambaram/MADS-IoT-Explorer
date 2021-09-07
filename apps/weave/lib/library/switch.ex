defmodule Weave.Library.Switch do
  alias Weave.Context

  defstruct kind: :local, fork: false
  @type t :: %__MODULE__{kind: atom(), fork: boolean()}

  defimpl Weave.Action do
    alias Weave.Library.Switch

    @spec data_sources(Switch.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(Switch.t()) :: [atom(), ...]
    def out_labels(_), do: [:telemetry, :platform]

    @spec exec(Switch.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
    def exec(_, %{type: type} = event, context) do
      {type, event, context}
    end
  end
end
