defmodule AcqdatCore.Schema.ToolManagement.ToolType do
  @moduledoc """
  Models a too type.
  """

  use AcqdatCore.Schema

  @type t :: %__MODULE__{}

  schema("acqdat_tm_tool_types") do
    field(:identifier, :string)
    field(:description, :string)

    timestamps(type: :utc_datetime)
  end

  @required ~w(identifier)a
  @optional ~w(description)a

  @permitted @required ++ @optional
  def changeset(%__MODULE__{} = tool_type, params) do
    tool_type
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:identifier, message: "Tool type already exists!")
  end
end
