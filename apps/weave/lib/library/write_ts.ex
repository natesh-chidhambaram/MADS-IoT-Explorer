defmodule Weave.Library.WriteTimeSeries do
  import Weave.Context

  @type write_ts_opts :: %{
          projections: [(map() -> any())]
        }
  defstruct kind: :db, fork: true, options: nil
  @type t :: %__MODULE__{kind: atom(), fork: boolean(), options: write_ts_opts()}

  defimpl Weave.Action do
    alias Weave.Library.WriteTimeSeries

    @spec data_sources(WriteTimeSeries.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(WriteTimeSeries.t()) :: [atom(), ...]
    def out_labels(_), do: [:ok, :err]

    @spec exec(WriteTimeSeries.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
    def exec(
          %{
            options: %{
              projections: projections
            }
          },
          event,
          context
        ) do
      with _args <- Enum.map(projections, fn projector -> projector.(event) end) do
        Weave.Constant.delay()
        {:ok, event, context}
      end
    end
  end
end
