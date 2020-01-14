defmodule AcqdatCore.Schema.Process do
  @moduledoc """
  Models a process in the site.

  A process will belongs to a particular site and will have many digital twins.
  """

  use AcqdatCore.Schema

  alias AcqdatCore.Schema.Site
  alias AcqdatCore.Schema.DigitalTwin

  @typedoc """
  `name`: Name for easy identification of the process.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_processes") do
    field(:name, :string)
    field(:image_url, :string)
    field(:image, :any, virtual: true)
    has_many(:digital_twins, DigitalTwin)
    belongs_to(:site, Site)
    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name site_id)a
  @optional_params ~w(image_url)a
  @permitted @required_params ++ @optional_params
  @update_required_params ~w(name)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = process, params) do
    process
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = process, params) do
    process
    |> cast(params, @permitted)
    |> validate_required(@update_required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:site)
    |> unique_constraint(:name, name: :unique_process_per_site)
  end
end
