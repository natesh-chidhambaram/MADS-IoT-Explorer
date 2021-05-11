defmodule AcqdatCore.DigitalTwin.Schema.DigitalTwin do
  @moduledoc """
  Models a Digital Twin in the process.

  A Digital Twin will belongs to a particular site and process.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
  alias AcqdatCore.Schema.RoleManagement.User

  @typedoc """
  `name`: Name for easy identification of the digital twin.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_digital_twins") do
    field(:name, :string)
    field(:metadata, :map)
    field(:description, :string)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:settings, :map)
    field(:opened_on, :utc_datetime)
    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:creator, User, on_replace: :delete)
    belongs_to(:project, Project, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name uuid slug opened_on org_id creator_id project_id)a
  @optional_params ~w(metadata description settings)a
  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = digital_twin, params) do
    digital_twin
    |> cast(params, @permitted)
    |> add_slug()
    |> add_uuid()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = digital_twin, params) do
    digital_twin
    |> cast(params, @permitted)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:creator)
    |> assoc_constraint(:project)
    |> unique_constraint(:name,
      name: :unique_dashboard_name_per_project_for_one_org,
      message: "Name already taken for this project under this organisation"
    )
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_slug(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:slug, Slugger.slugify(random_string(12)))
  end
end
