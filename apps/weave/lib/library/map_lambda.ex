defmodule Weave.Library.MapLambda do
  import Weave.Context

  @type map_lambda_opts :: %{
          projections: [(map() -> any())],
          program: (... -> any()),
          destination: {atom(), [String.t()]}
        }

  defstruct kind: :local, fork: false, options: nil
  @type t :: %__MODULE__{kind: atom(), fork: boolean(), options: map_lambda_opts()}

  defimpl Weave.Action do
    alias Weave.Library.MapLambda

    @spec data_sources(MapLambda.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(MapLambda.t()) :: [atom(), ...]
    def out_labels(_), do: [:ok, :err]

    @spec exec(MapLambda.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
    def exec(
          %{
            options: %{
              projections: projections,
              program: program,
              destination: {:event, path}
            }
          },
          event,
          context
        ) do
      with args <- Enum.map(projections, fn projector -> projector.(event) end),
           result <- apply(program, args) do
        {:ok, Map.put(event, List.first(path), result), context}
      end
    end
  end
end
