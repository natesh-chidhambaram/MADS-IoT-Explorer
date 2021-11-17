defmodule AcqdatCore.Schema.Streams.LoadOriginatorMetadata do
  @moduledoc """
  Loads the full metadata of the event originator to `destination`
  """
  use AcqdatCore.Schema

  @typedoc """
  `destination`: Destination (JSON path) where the metadata is placed.
  """
  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:destination, :string, null: false)
  end

  @all_params ~W(destination)a

  @doc """
  Creation changeset for `originator_metadata` action.
  """
  @spec create_changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def create_changeset(action, params) do
    action
    |> changeset(params)
    |> validate_required(@all_params)
  end

  @doc """
  Update changeset for `originator_metadata` action.
  """
  @spec update_changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def update_changeset(action, params) do
    changeset(action, params)
  end

  defp changeset(action, params) do
    action
    |> cast(params, @all_params)
    |> validate_format(:destination, ~r/^[[:alnum:]]+(?:\.[[:alnum:]]+)*$/)
  end
end
