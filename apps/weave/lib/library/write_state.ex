defmodule Weave.Library.WriteState do
  import Weave.Context

  @type write_state_opts :: %{
          projection: (map() -> any()),
          scope: atom(),
          destination: [String.t() | atom()]
        }
  defstruct kind: :local, fork: false, options: nil
  @type t :: %__MODULE__{kind: atom(), fork: boolean(), options: write_state_opts()}

  defimpl Weave.Action do
    alias Weave.Library.WriteState

    @spec data_sources(WriteState.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(WriteState.t()) :: [atom(), ...]
    def out_labels(_), do: [:ok, :err]

    @spec exec(WriteState.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
    def exec(
          %{
            options: %{
              projection: projection,
              scope: scope,
              destination: path
            }
          },
          event,
          context
        )
        when scope in [:device, :gateway, :project, :tenant] do
      {:ok, event,
       put_in(
         context,
         Enum.map([scope | path], fn key -> Access.key(key, %{}) end),
         projection.(event)
       )}
    end
  end
end
