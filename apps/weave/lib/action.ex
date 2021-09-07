defprotocol Weave.Action do
  import Weave.Context

  @spec data_sources(t) :: [atom(), ...]
  def data_sources(action)

  @spec out_labels(t) :: [atom(), ...]
  def out_labels(action)

  @spec exec(t, map(), Context.t()) :: {atom(), map(), Context.t()}
  def exec(action, event, context)
end