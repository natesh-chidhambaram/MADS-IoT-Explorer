defmodule AcqdatCore.DigitalTwin.Schema.Tab do
  @moduledoc """
  Models a Digital Twin in the process.

  A Digital Twin will belongs to a particular site and process.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.DigitalTwin.Schema.DigitalTwin

  @typedoc """
  `name`: Name for easy identification of the digital twin.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_tab") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:image, :any, virtual: true)
    field(:image_url, :string)
    field(:image_settings, :map)

    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:digital_twin, DigitalTwin, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name uuid slug org_id digital_twin_id)a
  @optional_params ~w(description image_url image_settings)a
  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = tab, params) do
    tab
    |> cast(params, @permitted)
    |> add_slug()
    |> add_uuid()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = tab, params) do
    tab
    |> cast(params, @permitted)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:digital_twin)
    |> unique_constraint(:name,
      name: :unique_tab_name_per_digital_twin,
      message: "Name already taken for this digital twin"
    )
  end
end
