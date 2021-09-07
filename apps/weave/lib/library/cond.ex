defmodule Weave.Library.Condition do
  import Weave.Context

  @type condition_opts :: %{
          projections: [(map() -> any())],
          predicate: (... -> boolean())
        }

  defstruct kind: :local, fork: false, options: nil
  @type t :: %__MODULE__{kind: atom(), fork: boolean(), options: condition_opts()}

  defimpl Weave.Action do
    alias Weave.Library.Condition

    @spec data_sources(Condition.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(Condition.t()) :: [atom(), ...]
    def out_labels(_), do: [true, false, :err]

    @spec exec(Condition.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
    def exec(
          %{
            options: %{
              projections: projections,
              predicate: predicate
            }
          },
          event,
          context
        ) do
      with args <- Enum.map(projections, fn projector -> projector.(event) end) do
        if apply(predicate, args) do
          {true, event, context}
        else
          {false, event, context}
        end
      end
    end
  end
end
