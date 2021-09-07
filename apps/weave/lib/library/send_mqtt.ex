defmodule Weave.Library.SendMqtt do
  import Weave.Context

  @type send_mqtt_opts :: %{
          projections: [(map() -> any())]
        }

  defstruct kind: :mqtt, fork: true, options: nil
  @type t :: %__MODULE__{kind: atom(), fork: boolean(), options: send_mqtt_opts()}

  defimpl Weave.Action do
    alias Weave.Library.SendMqtt

    @spec data_sources(SendMqtt.t()) :: [atom(), ...]
    def data_sources(_), do: [:event]

    @spec out_labels(SendMqtt.t()) :: [atom(), ...]
    def out_labels(_), do: [:ok, :err]

    @spec exec(SendMqtt.t(), map(), Context.t()) :: {atom(), map(), Context.t()}
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
	Weave.Constant.delay
        {:ok, event, context}
      end
    end
  end
end
