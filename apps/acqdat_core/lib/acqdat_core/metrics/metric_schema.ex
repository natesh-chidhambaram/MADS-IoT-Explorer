defmodule AcqdatCore.Schema.Metrics do
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.Metrics.Meta

  @type t :: %__MODULE__{
          inserted_time: DateTime.t(),
          org_id: integer(),
          metrics: map()
        }

  schema "acqdat_metrics" do
    field(:inserted_time, :utc_datetime, null: false)
    field(:org_id, :integer, null: false)
    embeds_one(:metrics, Meta)

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = metric, params) do
    metric
    |> cast(params, [:inserted_time, :org_id])
    |> cast_embed(:metrics, with: &Meta.changeset/2)
    |> validate_required([:inserted_time, :org_id])
  end
end

defmodule AcqdatCore.Schema.Metrics.Meta do
  alias AcqdatCore.Schema.Metrics.{Entities, Dashboards, DataInsights, RoleManager}

  use AcqdatCore.Schema

  embedded_schema do
    embeds_one(:entities, Entities)
    embeds_one(:dashboards, Dashboards)
    embeds_one(:data_insights, DataInsights)
    embeds_one(:role_manager, RoleManager)
  end

  @spec changeset(any, any) :: none
  def changeset(meta, params) do
    meta
    |> cast(params, [])
    |> cast_embed(:entities, with: &Entities.changeset/2)
    |> cast_embed(:dashboards, with: &Dashboards.changeset/2)
    |> cast_embed(:data_insights, with: &DataInsights.changeset/2)
    |> cast_embed(:role_manager, with: &RoleManager.changeset/2)
    |> validate_required([:entities, :dashboards, :data_insights, :role_manager])
  end
end

defmodule AcqdatCore.Schema.Metrics.Entities do
  use AcqdatCore.Schema

  embedded_schema do
    field(:sensors, :map)
    field(:sensor_types, :map)
    field(:assets, :map)
    field(:asset_types, :map)
    field(:projects, :map)
    field(:gateways, :map)
    field(:active_parameters, :map)
  end

  @required_params ~w(sensors sensor_types assets asset_types projects gateways active_parameters)a

  def changeset(entitymeta, params) do
    entitymeta
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end

defmodule AcqdatCore.Schema.Metrics.Dashboards do
  use AcqdatCore.Schema

  embedded_schema do
    field(:dashboards, :map)
    field(:panels, :map)
    field(:widgets, :map)
  end

  @required_params ~w(dashboards panels widgets)a

  def changeset(dashboardmeta, params) do
    dashboardmeta
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end

defmodule AcqdatCore.Schema.Metrics.DataInsights do
  use AcqdatCore.Schema

  embedded_schema do
    field(:fact_tables, :map)
    field(:visualisations, :map)
  end

  @required_params ~w(fact_tables visualisations)a

  def changeset(datainsightsmeta, params) do
    datainsightsmeta
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end

defmodule AcqdatCore.Schema.Metrics.RoleManager do
  use AcqdatCore.Schema

  embedded_schema do
    field(:users, :map)
  end

  @required_params ~w(users)a

  def changeset(rolemanagermeta, params) do
    rolemanagermeta
    |> cast(params, @required_params)
    |> validate_required(@required_params)
  end
end
