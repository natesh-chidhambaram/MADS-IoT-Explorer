defmodule AcqdatCore.Widgets.Schema.WidgetType do
  @moduledoc """
    Track down the different widgets that we have used from different vendors and whats the settings of each widget that we are storing
    Schema
  """

  use AcqdatCore.Schema

  alias AcqdatCore.Widgets.Schema.Widget

  @typedoc """
  'vendor': name of the vendor
  'module': widget schema
  'vendor metadata': it's metadata
  """

  @type t :: %__MODULE__{}

  schema("acqdat_widget_type") do
    field(:name, :string, null: false)
    field(:vendor, WidgetVendorEnum)
    field(:module, WidgetVendorSchemaEnum)
    field(:vendor_metadata, :map)

    # relationships
    has_many(:widget, Widget)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name vendor module)a
  @optional ~w(vendor_metadata)a
  @params @required ++ @optional

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = widget_type, params) do
    widget_type
    |> cast(params, @params)
    |> validate_required(@required)
  end

  def update_changeset(%__MODULE__{} = widget_type, params) do
    widget_type
    |> cast(params, @params)
  end
end
