defmodule AcqdatCore.Schema.Streams.Pipeline do
  @moduledoc """
  Models a project's action pipeline.

  A pipeline is a DAG of actions with a single root action. Telemtry pipelines
  are rooted with `Init`.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.Streams.Action
  alias AcqdatCore.Schema.EntityManagement.Project

  @typedoc """
  `id`: A UUID to identify the Pipeline.
  `project_id`: Pipeline's owner.
  """
  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema("acqdat_streams_pipelines") do
    field(:name, :string, null: false)
    field(:description, :string)

    # associations
    belongs_to(:project, Project, on_replace: :delete)
    has_many(:actions, Action)

    timestamps(type: :utc_datetime)
  end

  @required_params ~W(name project_id)a
  @optional_params ~W(description)a

  @all_params @required_params ++ @optional_params

  @spec changeset(t | Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  def changeset(action, params) do
    action
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:project)
    |> unique_constraint(:project)
  end
end
