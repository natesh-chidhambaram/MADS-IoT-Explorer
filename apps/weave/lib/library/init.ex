defmodule Weave.Library.Init do
  import Weave.Context

  defstruct kind: :local, fork: false
  @type t :: %__MODULE__{kind: atom(), fork: boolean()}

  defimpl Weave.Action do
    alias Weave.Library.Init

    @spec data_sources(Init.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(Init.t()) :: [atom(), ...]
    def out_labels(_), do: [:ok, :err]

    @spec exec(Init.t(), %{type: atom()}, Context.t()) :: {atom(), map(), Context.t()}
    def exec(_, %{type: type} = event, context) do
      {type, event, context}
    end
  end
end
