defmodule AcqdatCore.DashboardManagement.Schema.Subpanel do
  @moduledoc """
  Models a Dashboard's Subpanel Entity.

  Subpanels are used for grouping collection of widgets and providing them with a identifier.

  Any particular panel can have multiple subpanels.

  A Panel consists of multiple widgets.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.DashboardManagement.Schema.{CommandWidget, Dashboard, Panel, WidgetInstance}
  alias AcqdatCore.DashboardManagement.Schema.Subpanel.FilterMetadata

  @typedoc """
  `name`: Name of the subpanel, which will be unique with respective to panel.
  `settings`: All the settings of panel
  """

  @required_keys ~w(name org_id dashboard_id panel_id)a
  @cast_keys ~w(name description settings widget_layouts icon org_id dashboard_id panel_id )a
  @primary_key {:uuid, :binary_id, autogenerate: true}
  @type t :: %__MODULE__{}

  schema("acqdat_subpanel") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:settings, :map)
    field(:widget_layouts, :map)
    field(:icon, :string, default: "home")

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:dashboard, Dashboard, on_replace: :delete)
    belongs_to(:panel, Panel, on_replace: :delete)

    # embedded associations
    embeds_one(:filter_metadata, FilterMetadata, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = subpanel, params) do
    subpanel
    |> cast(params, @cast_keys)
    |> validate_required(@required_keys)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = subpanel, params) do
    subpanel
    |> cast(params, @cast_keys)
    |> validate_required(@required_keys)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def common_changeset(changeset) do
    changeset
    |> cast_embed(:filter_metadata, with: &FilterMetadata.changeset/2)
    |> assoc_constraint(:org)
    |> assoc_constraint(:dashboard)
    |> assoc_constraint(:panel)
    |> unique_constraint(:name,
      name: :unique_subpanel_name_per_pannel,
      message: "unique subpanel name under panel"
    )
  end
end

defmodule AcqdatCore.DashboardManagement.Schema.Subpanel.FilterMetadata do
  @moduledoc """
  Embed schema for filter_metadata related to panel.
  """

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:from_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:to_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:aggregate_func, :string, default: "max")
    field(:group_interval, :integer, default: 15)
    field(:group_interval_type, :string, default: "second")
    field(:last, :string, default: "2_hour")
    field(:type, :string, default: "realtime")
  end

  @cast_keys ~w(from_date to_date aggregate_func group_interval group_interval_type type last)a

  def changeset(%__MODULE__{} = settings, params) do
    cast(settings, params, @cast_keys)
  end
end
