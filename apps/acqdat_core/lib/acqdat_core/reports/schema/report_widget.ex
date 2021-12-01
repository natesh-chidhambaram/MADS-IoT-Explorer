defmodule AcqdatCore.Reports.Schema.ReportWidget do
  @moduledoc """
  WidgetInstance are instances of the class Widget, holding the same behaviour as that of widgets,
  but with different data-sources.

  It is used to model associations between a Report and widget.any()

  A report can have multiple widgets.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Widgets.Schema.Widget
  alias AcqdatCore.Reports.Schema.ReportWidget.SeriesData
  alias AcqdatCore.Reports.Schema.ReportWidget.FilterMetadata
  alias AcqdatCore.Reports.TemplateInstance

  schema("acqdat_reports_widgets") do
    field(:label, :string, null: false)
    field(:widget_settings, :map)
    field(:uuid, :string)
    field(:visual_properties, :map)
    field(:source_app, :string)
    field(:source_metadata, :map)

    # embedded associations
    embeds_one(:filter_metadata, FilterMetadata, on_replace: :delete)
    embeds_many(:series_data, SeriesData, on_replace: :delete)

    # associations
    belongs_to(:widget, Widget, on_replace: :delete)
    belongs_to(:template_instance, TemplateInstance, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(label widget_id template_instance_id)a
  @optional ~w(widget_settings visual_properties source_app source_metadata)a
  @permitted @required ++ @optional

  def changeset(%__MODULE__{} = report_widget, params) do
    report_widget
    |> cast(params, @permitted)
    |> add_uuid()
    |> cast_embed(:series_data, with: &SeriesData.changeset/2)
    |> cast_embed(:filter_metadata, with: &FilterMetadata.changeset/2)
    |> validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = report_widget, params) do
    report_widget
    |> cast(params, @permitted)
    |> cast_embed(:series_data, with: &SeriesData.changeset/2)
    |> cast_embed(:filter_metadata, with: &FilterMetadata.changeset/2)
    |> validate_required(@required)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> assoc_constraint(:widget)
    |> assoc_constraint(:template_instance)
  end
end

defmodule AcqdatCore.Reports.Schema.ReportWidget.FilterMetadata do
  @moduledoc """
  Embed schema for filter_metadata related to report.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:from_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:to_date, :integer, default: DateTime.to_unix(DateTime.utc_now(), :millisecond))
    field(:aggregate_func, :string, default: "max")
    field(:group_interval, :integer, default: 15)
    field(:group_interval_type, :string, default: "second")
    field(:last, :string, default: "2_hour")
    field(:type, :string, default: "realtime")
  end

  @permitted ~w(from_date to_date aggregate_func group_interval group_interval_type type last)a

  def changeset(%__MODULE__{} = settings, params) do
    settings
    |> cast(params, @permitted)
  end
end

defmodule AcqdatCore.Reports.Schema.ReportWidget.SeriesData do
  @moduledoc """
  Embed schema for Series Data and its data-sources.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Reports.Schema.ReportWidget.Axes

  embedded_schema do
    field(:name, :string)
    field(:color, :string)
    field(:unit, :string)
    embeds_many(:axes, Axes)
  end

  @permitted ~w(name color unit)a

  def changeset(%__MODULE__{} = series, params) do
    series
    |> cast(params, @permitted)
    |> cast_embed(:axes, with: &Axes.changeset/2)
  end
end

defmodule AcqdatCore.Reports.Schema.ReportWidget.Axes do
  @moduledoc """
  Embed schema for Axes of widget.
  """

  use AcqdatCore.Schema

  embedded_schema do
    field(:name, :string)
    field(:source_type, :string)
    field(:source_metadata, :map)
  end

  @permitted ~w(name source_type source_metadata)a
  def changeset(%__MODULE__{} = axes, params) do
    axes
    |> cast(params, @permitted)
  end
end
