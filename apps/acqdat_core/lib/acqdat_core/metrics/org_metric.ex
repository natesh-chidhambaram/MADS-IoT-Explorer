defmodule AcqdatCore.Metrics.OrgMetrics do
  @moduledoc """
  The module exposes all the helpers for getting the metrics for an organisation.
  """

  import Ecto.Query
  alias AcqdatCore.Repo

  alias AcqdatCore.Schema.EntityManagement.{
    Organisation,
    Asset,
    AssetType,
    Project,
    Sensor,
    SensorType,
    SensorsData
  }

  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.DashboardManagement.Schema.{Dashboard, Panel, WidgetInstance}
  alias AcqdatCore.Model.RoleManagement.User
  alias AcqdatCore.Model.DataInsights.{FactTables, Visualizations}
  alias AcqdatCore.Schema.Metrics

  def get(id) do
    case Repo.get(Metrics, id) do
      nil ->
        {:error, "Metrics not found"}

      metrics ->
        {:ok, metrics}
    end
  end

  @doc """
  Calculates all the parameters to be checked for an organisation and stores
  them in the database.
  """
  def measure_and_dump() do
    orgs = Repo.all(Organisation)
    stream = Task.async_stream(orgs, &assimilate_all_metrics/1, ordered: false)

    Enum.map(stream, fn metric ->
      {:ok, data} = metric
      org_id = data.org_id

      res =
        Metrics.changeset(%Metrics{}, %{
          inserted_time: DateTime.truncate(DateTime.utc_now(), :second),
          org_id: org_id,
          metrics: data
        })

      res |> Repo.insert!()
    end)
  end

  def assimilate_all_metrics(org) do
    org.id
    |> entity_manifest()
    |> Map.merge(dashboard_manifest(org.id))
    |> Map.merge(data_insights_manifest(org.id))
    |> Map.merge(role_manager_manifest(org.id))
  end

  # Get projects, assets, asset_types, sensors, sensor_types, gateways,
  # active parameters, for calculting active parameters use the current time
  # for day beginning and day end.
  def entity_manifest(org_id) do
    {asset_query, sensor_query, project_query} = entities_query(org_id)

    sensor_result = parse_sensors_data(sensor_query)
    asset_result = parse_asset_data(asset_query)
    project_result = parse_project_data(project_query)

    parameters_query = parameters_query(org_id, Timex.now())
    parameters_result = parse_parameters_data(parameters_query)

    %{
      org_id: org_id,
      entities: %{
        sensors: %{
          count: sensor_result.sensor_count,
          metadata: %{
            data:
              Enum.map(sensor_result.sensor_meta, fn asset ->
                %{id: asset["f1"], name: asset["f2"]}
              end)
          }
        },
        sensor_types: %{
          count: sensor_result.sensor_type_count,
          metadata: %{data: sensor_result.sensor_type_meta}
        },
        assets: %{
          count: asset_result.asset_count,
          metadata: %{
            data:
              Enum.map(asset_result.asset_meta, fn asset ->
                %{id: asset["f1"], name: asset["f2"]}
              end)
          }
        },
        asset_types: %{
          count: asset_result.asset_type_count,
          metadata: %{
            data:
              Enum.map(asset_result.asset_type_meta, fn asset_type ->
                %{id: asset_type.id, name: asset_type.name}
              end)
          }
        },
        projects: %{
          count: project_result.project_count,
          metadata: %{
            data:
              Enum.map(project_result.project_meta, fn project ->
                %{id: project.id, name: project.name}
              end)
          }
        },
        gateways: %{
          count: project_result.gateway_count,
          metadata: %{data: project_result.gateway_meta}
        },
        active_parameters: %{
          count: parameters_result.parameter_count,
          metadata: parameters_result.parameter_meta
        }
      }
    }
  end

  # Get all dashboards, projects and widgets.
  def dashboard_manifest(org_id) do
    query = dashboard_query(org_id)
    dashboard_results = parse_dashboard_parameters(query)

    %{
      dashboards: %{
        dashboards: %{
          count: dashboard_results.dashboard_count,
          metadata: %{data: dashboard_results.dashboard_meta}
        },
        panels: %{
          count: dashboard_results.panel_count,
          metadata: %{data: dashboard_results.panel_meta}
        },
        widgets: %{
          count: dashboard_results.widget_count,
          metadata: %{data: dashboard_results.widget_meta}
        }
      }
    }
  end

  # Get all fact tables and visualisations
  def data_insights_manifest(org_id) do
    fact_tables = FactTables.get_name_by_org(org_id)

    res = %{
      fact_tables: %{
        count: length(fact_tables),
        metadata: %{
          data: fact_tables
        }
      }
    }

    visual_tables = Visualizations.get_name_by_org(org_id)

    %{
      data_insights:
        res
        |> Map.merge(%{
          visualisations: %{
            count: length(visual_tables),
            metadata: %{
              data: visual_tables
            }
          }
        })
    }
  end

  # Get user information
  def role_manager_manifest(org_id) do
    users_cred = User.fetch_user_details_by_org(org_id)

    %{
      role_manager: %{
        users: %{
          count: length(users_cred),
          metadata: %{data: users_cred}
        }
      }
    }
  end

  # Get database size being used by an organisation
  # TODO implement database usage per organisation
  defp db_storage(_org_id) do
  end

  defp entities_query(org_id) do
    asset_query =
      from(
        asset_type in AssetType,
        left_join: asset in Asset,
        on: asset.asset_type_id == asset_type.id,
        where: asset_type.org_id == ^org_id,
        group_by: [asset_type.id, asset_type.name],
        select: %{
          asset_type_id: asset_type.id,
          asset_type_name: asset_type.name,
          asset_data: fragment("to_json(array_agg((?, ?)))", asset.id, asset.name),
          asset_count: count(asset.id)
        }
      )

    sensor_query =
      from(
        sensor_type in SensorType,
        left_join: sensor in Sensor,
        on: sensor.sensor_type_id == sensor_type.id,
        where: sensor_type.org_id == ^org_id,
        group_by: [sensor_type.id, sensor_type.name],
        select: %{
          sensor_type_id: sensor_type.id,
          sensor_type_name: sensor_type.name,
          sensor_data: fragment("to_json(array_agg((?,?)))", sensor.id, sensor.name),
          sensor_count: count(sensor.id)
        }
      )

    project_query =
      from(
        project in Project,
        left_join: gateway in Gateway,
        on: gateway.project_id == project.id,
        group_by: [project.name, project.id],
        where: project.org_id == ^org_id,
        select: %{
          project_name: project.name,
          project_id: project.id,
          gateway: fragment("to_json(array_agg((?,?)))", gateway.id, gateway.name),
          gateway_count: count(gateway.id)
        }
      )

    {asset_query, sensor_query, project_query}
  end

  # Gets the result of all the active parameters for the past day.
  # Active parameters are all the sensor parameters which have sent data on that
  # particular day. See `AcqdatCore.Schema.EntityManagement.SensorsData`
  # and `AcqdatCore.Schema.EntityManagement.Sensors`.
  defp parameters_query(org_id, time) do
    start_time = Timex.shift(time, days: -1)
    end_time = time

    subquery1 =
      from(
        sensor_data in SensorsData,
        where:
          sensor_data.org_id == ^org_id and
            sensor_data.inserted_timestamp > ^start_time and
            sensor_data.inserted_timestamp < ^end_time,
        distinct: true,
        select: %{sensor_id: sensor_data.sensor_id}
      )

    from(
      sensor in Sensor,
      join: q in subquery(subquery1),
      on: sensor.id == q.sensor_id,
      join: sensor_type in SensorType,
      on: sensor.sensor_type_id == sensor_type.id,
      select: {sensor.id, sensor.name, sensor_type.parameters}
    )
  end

  defp parse_sensors_data(query) do
    result = Repo.all(query)
    acc = %{sensor_count: 0, sensor_type_count: 0, sensor_type_meta: [], sensor_meta: []}

    Enum.reduce(result, acc, fn
      %{sensor_count: 0} = data, acc ->
        %{sensor_type_count: sensor_type_count, sensor_type_meta: sensor_type_meta} = acc

        %{
          acc
          | sensor_type_count: sensor_type_count + 1,
            sensor_type_meta: [
              %{id: data.sensor_type_id, name: data.sensor_type_name} | sensor_type_meta
            ]
        }

      data, acc ->
        %{
          sensor_type_count: sensor_type_count,
          sensor_type_meta: sensor_type_meta,
          sensor_count: sensor_count,
          sensor_meta: sensor_meta
        } = acc

        %{
          acc
          | sensor_type_count: sensor_type_count + 1,
            sensor_type_meta: [
              %{id: data.sensor_type_id, name: data.sensor_type_name} | sensor_type_meta
            ],
            sensor_count: sensor_count + data.sensor_count,
            sensor_meta: data.sensor_data ++ sensor_meta
        }
    end)
  end

  defp parse_asset_data(query) do
    result = Repo.all(query)
    acc = %{asset_count: 0, asset_type_count: 0, asset_type_meta: [], asset_meta: []}

    Enum.reduce(result, acc, fn
      %{asset_count: 0} = data, acc ->
        %{asset_type_count: asset_type_count, asset_type_meta: asset_type_meta} = acc

        %{
          acc
          | asset_type_count: asset_type_count + 1,
            asset_type_meta: [
              %{id: data.asset_type_id, name: data.asset_type_name} | asset_type_meta
            ]
        }

      data, acc ->
        %{
          asset_type_count: asset_type_count,
          asset_type_meta: asset_type_meta,
          asset_count: asset_count,
          asset_meta: asset_meta
        } = acc

        %{
          acc
          | asset_type_count: asset_type_count + 1,
            asset_type_meta: [
              %{id: data.asset_type_id, name: data.asset_type_name} | asset_type_meta
            ],
            asset_count: asset_count + data.asset_count,
            asset_meta: data.asset_data ++ asset_meta
        }
    end)
  end

  defp parse_project_data(query) do
    result = Repo.all(query)
    acc = %{project_count: 0, project_meta: [], gateway_count: 0, gateway_meta: []}

    Enum.reduce(result, acc, fn
      %{gateway_count: 0} = data, acc ->
        %{project_count: project_count, project_meta: project_meta} = acc

        %{
          acc
          | project_count: project_count + 1,
            project_meta: [%{id: data.project_id, name: data.project_name} | project_meta]
        }

      data, acc ->
        %{
          project_count: project_count,
          project_meta: project_meta,
          gateway_count: gateway_count,
          gateway_meta: gateway_meta
        } = acc

        %{
          acc
          | project_count: project_count + 1,
            project_meta: [%{id: data.project_id, name: data.project_name} | project_meta],
            gateway_count: gateway_count + data.gateway_count,
            gateway_meta: data.gateway ++ gateway_meta
        }
    end)
  end

  # TODO: Need to check this function
  defp parse_parameters_data(query) do
    result = Repo.all(query)
    acc = %{parameter_count: 0, parameter_meta: []}

    Enum.reduce(result, acc, fn {sensor_id, sensor_name, params}, acc ->
      parameter_count = length(params) + acc.parameter_count
      parameter_meta = [%{id: sensor_id, name: sensor_name} | acc.parameter_meta]
      %{acc | parameter_count: parameter_count, parameter_meta: parameter_meta}
    end)
  end

  def dashboard_query(org_id) do
    subquery1 =
      from(
        panel in Panel,
        left_join: instance in WidgetInstance,
        on: instance.panel_id == panel.id,
        where: panel.org_id == ^org_id,
        group_by: [panel.id, panel.name],
        select: %{
          panel_id: panel.id,
          panel_name: panel.name,
          widget_instance_data: fragment("array_agg((?, ?))", instance.uuid, instance.label),
          dashboard_id: panel.dashboard_id,
          widget_count: count(instance.uuid)
        }
      )

    from(
      dashboard in Dashboard,
      left_join: q1 in subquery(subquery1),
      on: q1.dashboard_id == dashboard.id,
      group_by: [dashboard.id, dashboard.name],
      where: dashboard.org_id == ^org_id,
      select: %{
        dashboard_id: dashboard.id,
        dashboard_name: dashboard.name,
        panel_data:
          fragment(
            "to_json(array_agg((?,?,?,?)))",
            q1.panel_id,
            q1.panel_name,
            q1.widget_instance_data,
            q1.widget_count
          )
      }
    )
  end

  defp parse_dashboard_parameters(query) do
    result = Repo.all(query)

    acc = %{
      dashboard_count: 0,
      dashboard_meta: [],
      panel_count: 0,
      panel_meta: [],
      widget_count: 0,
      widget_meta: []
    }

    Enum.reduce(result, acc, fn data, acc ->
      panel_acc = %{
        panel_count: acc.panel_count,
        panel_meta: acc.panel_meta,
        widget_count: acc.widget_count,
        widget_meta: acc.widget_meta
      }

      panel_data =
        Enum.reduce(data.panel_data, panel_acc, fn
          %{"f4" => 0} = panel_data, panel_acc ->
            %{
              panel_acc
              | panel_count: panel_acc.panel_count + 1,
                panel_meta: [
                  %{id: panel_data["f1"], name: panel_data["f2"]} | panel_acc.panel_meta
                ]
            }

          panel_data, panel_acc ->
            widget_meta =
              Enum.map(panel_data["f3"], fn data ->
                %{id: data["f1"], name: data["f2"]}
              end)

            widget_count = panel_data["f4"]

            %{
              panel_acc
              | panel_count: panel_acc.panel_count + 1,
                panel_meta: [
                  %{id: panel_data["f1"], name: panel_data["f2"]} | panel_acc.panel_meta
                ],
                widget_count: widget_count + panel_acc.widget_count,
                widget_meta: panel_acc.widget_meta ++ widget_meta
            }
        end)

      %{
        acc
        | dashboard_count: acc.dashboard_count + 1,
          dashboard_meta: [
            %{id: data.dashboard_id, name: data.dashboard_name} | acc.dashboard_meta
          ],
          panel_count: panel_data.panel_count,
          panel_meta: panel_data.panel_meta,
          widget_count: panel_data.widget_count,
          widget_meta: panel_data.widget_meta
      }
    end)
  end
end
