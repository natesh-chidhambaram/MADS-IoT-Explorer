defmodule AcqdatApi.DashboardManagement.Panel do
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias Ecto.Multi
  alias AcqdatApi.DashboardManagement.Subpanel
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.DashboardManagement.Schema.Panel

  defdelegate delete(panel), to: PanelModel
  defdelegate get_with_widgets(panel_id), to: PanelModel
  defdelegate update(panel, data), to: PanelModel

  def get_all(%{dashboard_id: dashboard_id}) do
    {:ok, dashboard} = DashboardModel.get_with_panels(dashboard_id)
    dashboard.panels
  end

  def create(attrs) do
    %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      settings: settings,
      filter_metadata: filter_metadata,
      widget_layouts: widget_layouts,
      icon: icon
    } = attrs

    panel_params = %{
      name: name,
      description: description,
      org_id: org_id,
      dashboard_id: dashboard_id,
      settings: settings,
      icon: icon,
      filter_metadata:
        filter_metadata ||
          %{from_date: from_date, to_date: DateTime.to_unix(DateTime.utc_now(), :millisecond)},
      widget_layouts: widget_layouts
    }

    verify_panel(PanelModel.create(panel_params))
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
        create_widget_instance_in_panel(panel_details.widget_instances, sub_panel)
      end)
      |> run_transaction()
    else
      Multi.new()
      |> Multi.run(:create_panel, fn _, _changes ->
        create_params(panel, data)
        |> PanelModel.create()
      end)
      |> Multi.run(:create_widget_instance, fn _, %{create_panel: panel} ->
        create_widget_instance_in_panel(panel_details.widget_instances, panel)
      end)
      |> Multi.run(:create_sub_panel, fn _, %{create_widget_instance: root_panel} ->
        subpanel_attrs = create_subpanel_attributes(panel_details.children, root_panel)
        Repo.insert_all(Panel, subpanel_attrs)
        {:ok, root_panel}
      end)
      |> run_transaction()
    end
  end

  defp verify_panel({:ok, panel}) do
    {:ok, panel}
  end

  defp verify_panel({:error, panel}) do
    {:error, %{error: extract_changeset_error(panel)}}
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

  defp create_widget_instance_in_panel(widget_instances, panel) do
    attrs = create_widget_instance_attributes(widget_instances, panel)
    WidgetInstanceModel.bulk_create(attrs)
    {:ok, panel}
  end

  defp create_widget_instance_attributes(widget_instances, panel) do
    Enum.reduce(widget_instances, [], fn instance, acc ->
      acc ++ [widget_create_attrs(instance, panel)]
    end)
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
end
