defmodule AcqdatApi.DataInsights.Visualizations do
  alias AcqdatCore.Model.DataInsights.Visualizations
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance
  alias AcqdatCore.Model.Widgets.Widget
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  defdelegate get_all_visualization_types(), to: Visualizations
  defdelegate get_all(params), to: Visualizations
  defdelegate create(params), to: Visualizations
  defdelegate delete(visualization), to: Visualizations
  defdelegate update(visualization, data), to: Visualizations

  def gen_data(visualization_id) do
    case Visualizations.get(visualization_id) do
      {:ok, visualization} ->
        module = visualization.module

        case module.data_prop_gen(visualization) do
          {:ok, data} ->
            if module.visualization_type == "PivotTables" do
              {:ok, Map.put(visualization, :gen_data, data)}
            else
              case Visualizations.update(visualization, %{
                     chart_category: data[:chart_category],
                     visual_settings:
                       module.visual_prop_gen(visualization, %{
                         chart_category: data[:chart_category]
                       })
                   }) do
                {:ok, visualization} ->
                  {:ok, Map.put(visualization, :gen_data, data)}

                {:error, message} ->
                  {:error, message}
              end
            end

          {:error, message} ->
            {:error, message}
        end

      {:error, message} ->
        {:error, message}
    end
  end

  def fetch_series_data(widget) do
    case Visualizations.get(widget.source_metadata["source_id"]) do
      {:ok, visualization} ->
        module = visualization.module

        case module.data_prop_gen(visualization) do
          {:ok, res} ->
            data =
              if widget.widget.category == ["pivot_table"],
                do: [res.headers] ++ res.data,
                else: res.data

            Map.put(widget, :series, data)

          {:error, _} ->
            widget
        end

      {:error, _} ->
        widget
    end
  end

  def validate_widget(%{id: visualization_id}) do
    case WidgetInstance.get_by_src(%{
           source_type: "AcqdatApi.DataInsights.Visualizations",
           source_id: "#{visualization_id}"
         }) do
      [] ->
        {:ok, true}

      _ ->
        {:error,
         "Updating this Visualizations will change it to all the dashboards, where is it exported"}
    end
  end

  def export(visualization, %{"panel_id" => panel_id, "title" => title}) do
    data = %{
      label: title,
      panel_id: panel_id
    }

    with {:validate, {:ok, true}} <- {:validate, valid_export?(panel_id, visualization.id)},
         {:fetch_widget, {:ok, widget}} <- {:fetch_widget, fetch_widget(visualization)} do
      visual_properties =
        Map.merge(HighCharts.parse_properties(widget.visual_settings), %{
          "title" => %{"text" => "#{title}"}
        })

      data = %{
        label: title,
        panel_id: panel_id,
        widget_id: widget.id,
        source_app: "data_insights",
        visual_properties: Map.merge(visual_properties, visualization.visual_settings || %{}),
        source_metadata: %{
          source_type: "AcqdatApi.DataInsights.Visualizations",
          source_id: visualization.id
        }
      }

      AcqdatApi.DashboardManagement.WidgetInstance.create(data)
    else
      {:validate, {:error, error}} ->
        {:error, error}

      {:fetch_widget, {:error, error}} ->
        {:error, "widget not found for the respective visualization"}
    end
  end

  def valid_export?(panel_id, visualization_id) do
    widget_inst =
      WidgetInstance.get_by_panel_n_src(
        panel_id,
        %{
          source_type: "AcqdatApi.DataInsights.Visualizations",
          source_id: "#{visualization_id}"
        }
      )

    if widget_inst == [],
      do: {:ok, true},
      else: {:error, "Visualization already exported to this Panel"}
  end

  defp fetch_widget(visualization) do
    # TODO: Need to handle for heat_map and pivot_table visualizations
    widget_label =
      case {visualization.type, visualization.chart_category} do
        {:Lines, "highchart"} ->
          "line"

        {:Lines, "stock_chart"} ->
          "Stock Single line series"

        {:Area, "highchart"} ->
          "area"

        {:Area, "stock_chart"} ->
          "Area Range"

        {:Column, "highchart"} ->
          "Basic Column"

        {:Column, "stock_chart"} ->
          "Stacked Column"

        {:HeatMap, "anychart"} ->
          "HeatMap"

        {:PivotTables, _} ->
          "PivotTable"

        _ ->
          "default"
      end

    Widget.get_by_label(widget_label)
  end
end
