defmodule AcqdatCore.Schema.Streams.Action do
  @moduledoc """
  Base type of all pipeline Actions

  An action belongs to one Pipeline and is deleted if the pipeline is removed.
  """
  use AcqdatCore.Schema
  import PolymorphicEmbed, only: [cast_polymorphic_embed: 3]
  alias AcqdatCore.Schema.Streams.{Pipeline, Init}

  @typedoc """
  `id`: A UUID to identify the Action.
  `type`: The 'kind' of action, an action has a unique `type`.
  `name`: Display name of the Action.
  `pipeline`: Parent `Streams.Pipeline`
  """
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema("acqdat_streams_actions") do
    field(:type, StreamsActionTypeEnum, null: false)
    field(:name, :string)

    field(:config, PolymorphicEmbed,
      types: [
        init: Init
      ],
      type_field: :type,
      on_replace: :update
    )

    # associations
    belongs_to(:pipeline, Pipeline, on_replace: :delete, type: :binary_id)

    timestamps(type: :utc_datetime)
  end

  @required_params ~W(type pipeline_id)a
  @mutable_params ~W(name)a
  @all_params @required_params ++ @mutable_params

  @action_types ~W(init switch transform condition save webhook originator_metadata previous write_ts read_ts)a

  @spec create_changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def create_changeset(action, params) do
    action
    |> cast(params, @all_params)
    |> validate_inclusion(:type, @action_types)
    |> validate_required(@required_params)
    |> assoc_constraint(:pipeline)
    |> cast_polymorphic_embed(:config,
      required: true,
      with: [
        init: &Init.create_changeset/2
      ]
    )
  end

  @spec update_changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def update_changeset(action, params) do
    action
    |> cast(params, @mutable_params)
    |> cast_polymorphic_embed(:config, with: [])
  end
end
