defmodule Weave.Library.ReadTimeSeries do
  alias Weave.Context

  @type read_ts_opts :: %{
          projection: (map() -> any()),
          destination: [String.t()]
        }

  defstruct kind: :db, fork: true, options: nil
  @type t :: %__MODULE__{kind: atom(), fork: boolean(), options: read_ts_opts()}

  defimpl Weave.Action do
    alias Weave.Library.ReadTimeSeries

    @spec data_sources(ReadTimeSeries.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(ReadTimeSeries.t()) :: [atom(), ...]
    def out_labels(_), do: [:ok, :err]

    @spec exec(ReadTimeSeries.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
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
      Weave.Constant.delay()
      {:ok, Map.put(event, List.first(path), projection.(event)), context}
    end
  end
end
