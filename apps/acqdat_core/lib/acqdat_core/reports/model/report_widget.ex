defmodule AcqdatCore.Reports.Model.ReportWidget do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Reports.Schema.ReportWidget
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  def create(params) do
    changeset = ReportWidget.changeset(%ReportWidget{}, params)
    Repo.insert(changeset)
  end

  def get_by_filter(id, filter_params) when is_integer(id) do
    case Repo.get(ReportWidget, id) |> Repo.preload([:widget]) do
      nil ->
        {:error, "widget instance in this report with this id not found"}

      report_widget ->
        filtered_params = parse_filtered_params(filter_params, report_widget.filter_metadata)

        widget_instance_data =
          if report_widget.source_app != nil do
            module = Module.safe_concat([report_widget.source_metadata["source_type"]])

            module.fetch_series_data(report_widget)
          else
            report_widget |> HighCharts.fetch_highchart_details(filtered_params)
          end

        {:ok, widget_instance_data}
    end
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(ReportWidget, id) do
      nil ->
        {:error, "widget_instance with this id not found"}

      widget_instance ->
        {:ok, widget_instance}
    end
  end

  def update(widget_instance, params) do
    changeset = ReportWidget.update_changeset(widget_instance, params)
    Repo.update(changeset)
  end

  def delete(widget_instance) do
    Repo.delete(widget_instance)
  end

  defp parse_filtered_params(params, %{
         filter_metadata: %{
           from_date: from_date,
           to_date: to_date,
           aggregate_func: aggr_fun,
           group_interval: grp_intv,
           group_interval_type: grp_intv_type
         }
       }) do
    %{
      from_date:
        from_unix(
          if(params["from_date"], do: String.to_integer(params["from_date"]), else: from_date)
        ),
      to_date:
        from_unix(if(params["to_date"], do: String.to_integer(params["to_date"]), else: to_date)),
      aggregate_func: if(params["aggregate_func"], do: params["aggregate_func"], else: aggr_fun),
      group_interval: if(params["group_interval"], do: params["group_interval"], else: grp_intv),
      group_interval_type:
        if(params["group_interval_type"], do: params["group_interval_type"], else: grp_intv_type)
    }
  end

  defp parse_filtered_params(_, _) do
    %{
      from_date: Timex.shift(Timex.now(), months: -1),
      to_date: Timex.now(),
      aggregate_func: "max",
      group_interval: 1,
      group_interval_type: "hour"
    }
  end

  defp from_unix(datetime) do
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end
end
