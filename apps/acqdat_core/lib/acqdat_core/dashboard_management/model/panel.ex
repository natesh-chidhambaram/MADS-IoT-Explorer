defmodule AcqdatCore.Model.DashboardManagement.Panel do
  import Ecto.Query
  alias Ecto.Multi
  alias AcqdatCore.DashboardManagement.Schema.Panel
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.Model.DashboardManagement.CommandWidget
  alias AcqdatCore.Repo
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DashboardManagement.Subpanel

  def create(params) do
    changeset = Panel.changeset(%Panel{}, params)
    Repo.insert(changeset)
  end

  @doc """
  For panel duplication, if the received request contains value for parent-id, then the target is going to be subpanel which comes under the received parent-id.
  Else the target is going to be the root panel.
  We are having One level hirerchy for panel and it's children (Widgets and subpanels).
  So, we can duplicate a subpanel as root panel or as a subpanel.
  But, if the root panel has subpanels then we can duplicate it only as a root panel, we can't make the target duplication to be a subpanel.
  """
  def duplicate(panel, data) do
    panel_details = Repo.preload(panel, [:widget_instances, :children])

    if data.parent_id != nil do
      Multi.new()
      |> Multi.run(:create_sub_panel, fn _, _changes ->
        create_subpanel_params(panel, data)
        |> Subpanel.create()
      end)
      |> Multi.run(:create_widget_instance, fn _, %{create_sub_panel: sub_panel} ->
        attrs = create_widget_instance_attributes(panel_details.widget_instances, sub_panel)
        WidgetInstanceModel.bulk_create(attrs)
        {:ok, sub_panel}
      end)
      |> run_transaction()
    else
      Multi.new()
      |> Multi.run(:create_panel, fn _, _changes ->
        create_params(panel, data)
        |> create()
      end)
      |> Multi.run(:create_widget_instance, fn _, %{create_panel: panel} ->
        attrs = create_widget_instance_attributes(panel_details.widget_instances, panel)
        WidgetInstanceModel.bulk_create(attrs)
        {:ok, panel}
      end)
      |> Multi.run(:createe_sub_panel, fn _, %{create_widget_instance: root_panel} ->
        subpanel_attrs = create_subpanel_attributes(panel_details.children, root_panel)
        Repo.insert_all(Panel, subpanel_attrs)
        {:ok, root_panel}
      end)
      |> run_transaction()
    end
  end

  def update(panel, params) do
    changeset = Panel.update_changeset(panel, params)
    Repo.update(changeset)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Panel, id) do
      nil ->
        {:error, "panel with this id not found"}

      panel ->
        {:ok, panel}
    end
  end

  def get_all_by_parent_id(parent_id) do
    query = from(s in Panel, where: s.parent_id == ^parent_id)

    Repo.all(query)
  end

  def get_with_widgets(id, %{"filter_metadata" => filter_metadata}) do
    case Repo.get(Panel, id) do
      nil ->
        {:error, "panel with this id not found"}

      panel ->
        filter_params =
          %{filter_metadata: transform_map(filter_metadata)} |> compute_filtered_params(panel)

        fetch_panel_widgets_data(panel, filter_params)
    end
  end

  def get_with_widgets(id) do
    case Repo.get(Panel, id) do
      nil ->
        {:error, "panel with this id not found"}

      panel ->
        filter_params = panel |> parse_filtered_params
        fetch_panel_widgets_data(panel, filter_params)
    end
  end

  def delete(panel) do
    Repo.delete(panel)
  end

  def delete_all(ids) when is_list(ids) do
    from(panel in Panel, where: panel.id in ^ids)
    |> Repo.delete_all()
  end

  defp create_widget_instance_attributes(widget_instances, panel) do
    Enum.reduce(widget_instances, [], fn instance, acc ->
      acc ++ [widget_create_attrs(instance, panel)]
    end)
  end

  defp create_subpanel_attributes(subpanels, panel) do
    Enum.reduce(subpanels, [], fn subpanel, acc ->
      acc ++ [subpanel_create_attrs(subpanel, panel)]
    end)
  end

  defp subpanel_create_attrs(
         %{
           name: name,
           icon: icon,
           description: description,
           org_id: org_id,
           settings: settings,
           filter_metadata: filter_metadata,
           widget_layouts: widget_layouts
         },
         panel
       ) do
    datetime = DateTime.truncate(DateTime.utc_now(), :second)

    %{
      uuid: UUID.uuid1(:hex),
      slug: Slugger.slugify(random_string(12)),
      inserted_at: datetime,
      updated_at: datetime,
      name: name,
      icon: icon,
      parent_id: panel.id,
      dashboard_id: panel.dashboard_id,
      description: description,
      org_id: org_id,
      settings: settings,
      filter_metadata:
        filter_metadata ||
          %{from_date: from_date, to_date: DateTime.to_unix(DateTime.utc_now(), :millisecond)},
      widget_layouts: widget_layouts
    }
  end

  defp from_date do
    DateTime.to_unix(Timex.shift(DateTime.utc_now(), hours: -2), :millisecond)
  end

  defp create_params(
         %{
           description: description,
           filter_metadata: filter_metadata,
           org_id: org_id,
           settings: settings,
           widget_layouts: widget_layouts
         },
         %{icon: icon, name: name, target_dashboard_id: dashboard_id}
       ) do
    (filter_metadata && Map.from_struct(filter_metadata)) ||
      %{
        dashboard_id: dashboard_id,
        description: description,
        filter_metadata:
          (filter_metadata && Map.from_struct(filter_metadata)) ||
            %{from_date: from_date, to_date: DateTime.to_unix(DateTime.utc_now(), :millisecond)},
        icon: icon,
        name: name,
        org_id: org_id,
        settings: settings,
        widget_layouts: widget_layouts
      }
  end

  defp create_subpanel_params(
         %{
           description: description,
           org_id: org_id,
           settings: settings,
           filter_metadata: filter_metadata,
           widget_layouts: widget_layouts
         },
         %{
           name: name,
           icon: icon,
           target_dashboard_id: dashboard_id,
           parent_id: parent_id,
           panel_id: panel_id
         }
       ) do
    %{
      name: name,
      icon: icon,
      parent_id: parent_id,
      panel_id: panel_id,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      settings: settings,
      filter_metadata: Map.from_struct(filter_metadata),
      widget_layouts: widget_layouts
    }
  end

  defp fetch_panel_widgets_data(panel, filter_params) do
    widgets = WidgetInstanceModel.get_all_by_panel_id(panel.id, filter_params)
    command_widgets = CommandWidget.get_all_by_panel_id(panel.id)
    subpanels = get_all_by_parent_id(panel.id)

    panel =
      panel
      |> Map.put(:widgets, widgets)
      |> Map.put(:command_widgets, command_widgets)
      |> Map.put(:subpanels, subpanels)

    {:ok, panel}
  end

  defp compute_filtered_params(%{filter_metadata: user_filter_metadata}, %{
         filter_metadata: panel_filter_metadata
       }) do
    from_date = user_filter_metadata[:from_date] || panel_filter_metadata.from_date
    to_date = user_filter_metadata[:to_date] || panel_filter_metadata.to_date
    aggregate_func = user_filter_metadata[:aggregate_func] || panel_filter_metadata.aggregate_func
    group_interval = user_filter_metadata[:group_interval] || panel_filter_metadata.group_interval

    group_interval_type =
      user_filter_metadata[:group_interval_type] || panel_filter_metadata.group_interval_type

    last = user_filter_metadata[:last] || panel_filter_metadata.last

    parse_filtered_params(%{
      filter_metadata: %{
        from_date: from_date,
        to_date: to_date,
        aggregate_func: aggregate_func,
        group_interval: group_interval,
        group_interval_type: group_interval_type,
        last: last
      }
    })
  end

  defp parse_filtered_params(%{
         filter_metadata: %{
           from_date: from_date,
           to_date: to_date,
           aggregate_func: aggr_fun,
           group_interval: grp_intv,
           group_interval_type: grp_intv_type,
           last: last
         }
       }) do
    %{from_date: from_date, to_date: to_date} = fetch_datetime_range(from_date, to_date, last)

    %{
      from_date: from_date,
      to_date: to_date,
      aggregate_func: aggr_fun,
      group_interval: grp_intv,
      group_interval_type: grp_intv_type
    }
  end

  defp parse_filtered_params(_panel) do
    %{
      from_date: Timex.shift(Timex.now(), hours: -2),
      to_date: Timex.now(),
      aggregate_func: "max",
      group_interval: 15,
      group_interval_type: "second",
      last: "2_hour"
    }
  end

  defp fetch_datetime_range(from_date, to_date, last) when last == "custom" do
    %{from_date: from_unix(from_date), to_date: from_unix(to_date)}
  end

  defp fetch_datetime_range(_from_date, _to_date, last) do
    [interval, duration] = String.split(last, "_")
    {interval, _} = Integer.parse(interval)
    to_date = DateTime.utc_now()

    from_date = to_date |> from_date(duration, interval)

    %{from_date: from_date, to_date: to_date}
  end

  defp from_date(to_date, duration, interval) do
    duration = String.to_atom(duration <> "s")
    Timex.shift(to_date, [{duration, -interval}])
  end

  defp from_unix(datetime) do
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end

  defp transform_map(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

  defp widget_create_attrs(
         %{
           label: label,
           widget_id: widget_id,
           series_data: series_data,
           widget_settings: widget_settings,
           visual_properties: visual_properties
         },
         panel
       ) do
    datetime = DateTime.truncate(DateTime.utc_now(), :second)

    %{
      uuid: UUID.uuid1(:hex),
      slug: Slugger.slugify(random_string(12)),
      inserted_at: datetime,
      updated_at: datetime,
      label: label,
      panel_id: panel.id,
      widget_id: widget_id,
      series_data: series_data,
      widget_settings: widget_settings,
      visual_properties: visual_properties
    }
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{create_panel: panel, create_widget_instance: _widget_instance}} ->
        {:ok, panel}

      {:ok, %{create_sub_panel: sub_panel, create_widget_instance: _widget_instance}} ->
        {:ok, sub_panel}

      {:error, failed_operation, failed_value, _changes_so_far} ->
        case failed_operation do
          :create_panel -> verify_error_changeset({:error, failed_value})
          :create_sub_panel -> verify_error_changeset({:error, failed_value})
          :create_widget_instance -> verify_error_changeset({:error, failed_value})
        end
    end
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end

  defp widget_create_attrs(
         %{
           label: label,
           widget_id: widget_id,
           source_app: source_app,
           source_metadata: source_metadata,
           visual_properties: visual_properties
         },
         panel
       ) do
    %{
      label: label,
      panel_id: panel.id,
      widget_id: widget_id,
      source_app: source_app,
      source_metadata: source_metadata,
      visual_properties: visual_properties
    }
  end
end
