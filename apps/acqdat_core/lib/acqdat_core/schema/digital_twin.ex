defmodule AcqdatCore.Schema.DigitalTwin do
  @moduledoc """
  Models a Digital Twin in the process.

  A Digital Twin will belongs to a particular site and process.
  """

  use AcqdatCore.Schema

  alias AcqdatCore.Schema.Site
  alias AcqdatCore.Schema.Process

  @typedoc """
  `name`: Name for easy identification of the digital twin.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_digital_twins") do
    field(:name, :string)
    field(:metadata, :map)
    belongs_to(:process, Process)
    belongs_to(:site, Site)
    timestamps(type: :utc_datetime)
  end

  @mutual_exclusive_fields ~w(site_id process_id)a
  @required_params ~w(name)a
  @optional_params ~w(metadata site_id process_id)a
  @permitted @required_params ++ @optional_params
  @update_required_params ~w(name)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = digital_twin, params) do
    digital_twin
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> validate_mutual_exclusive(@mutual_exclusive_fields)
  end

  def update_changeset(%__MODULE__{} = digital_twin, params) do
    digital_twin
    |> cast(params, @permitted)
    |> validate_required(@update_required_params)
    |> validate_mutual_exclusive(@mutual_exclusive_fields)
  end

  defp validate_mutual_exclusive(changeset, fields) do
    present = Enum.count(fields, fn field -> present?(get_field(changeset, field)) end)

    case present do
      1 ->
        changeset

      _ ->
        add_error(
          changeset,
          :missing_or_mutual_exclusive_error,
          "Either no ID is not present or both are present"
        )
    end
  end

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(_), do: true
end
