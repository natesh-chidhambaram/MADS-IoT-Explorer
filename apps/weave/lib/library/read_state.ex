defmodule Weave.Library.ReadState do
  import Weave.Context

  @type read_state_opts :: %{
          projection: (Context.t() -> any()),
          destination: [String.t()]
        }

  defstruct kind: :local, fork: false, options: nil
  @type t :: %__MODULE__{kind: atom(), fork: boolean(), options: read_state_opts()}

  defimpl Weave.Action do
    alias Weave.Library.ReadState

    @spec data_sources(ReadState.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(ReadState.t()) :: [atom(), ...]
    def out_labels(_), do: [:ok, :err]

    @spec exec(ReadState.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
    def exec(
          %{
            options: %{
              projection: projection,
              destination: path
            }
          },
          event,
          context
        ) do
      {:ok, Map.put(event, List.first(path), projection.(context)), context}
    end
  end
end
