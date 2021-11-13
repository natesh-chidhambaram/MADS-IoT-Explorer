defmodule AcqdatCore.Schema.Streams.Init do
  @moduledoc """
  The root action for all telemetry pipelines.
  """
  use AcqdatCore.Schema

  @typedoc """
  Currently this type has no fields.
  """
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
  end

  @doc """
  Changeset for creating `init` action.
  """
  @spec changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(init, _) do
    cast(init, %{}, [])
  end
end
