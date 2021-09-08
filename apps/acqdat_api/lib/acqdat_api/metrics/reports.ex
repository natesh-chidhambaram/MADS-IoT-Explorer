defmodule AcqdatApi.Metrics.Reports do
  alias AcqdatCore.Metrics.Reports
  alias AcqdatCore.Schema.Metrics.{Meta, Entities, Dashboards, DataInsights, RoleManager}

  def fetch_metrics_headers() do
    apps = Map.from_struct(Meta) |> Map.drop([:id])

    Enum.reduce(apps, %{}, fn {key, _value}, acc ->
      module = key |> Atom.to_string() |> Macro.camelize()

      sections =
        ["AcqdatCore.Schema.Metrics.#{module}"]
        |> Module.safe_concat()
        |> Map.from_struct()
        |> Map.drop([:id])
        |> Map.keys()

      Map.put(acc, key, sections)
    end)
  end

  def gen_report(%{
        "org_id" => org_id,
        "start_date" => start_date,
        "end_date" => end_date,
        "type" => type,
        "app" => app,
        "entity" => entity,
        "group_action" => group_action
      }) do
    end_date = end_date |> string_to_date()
    start_date = start_date |> string_to_date()
    Reports.range_report(org_id, start_date, end_date, type, app, entity, group_action)
  end

  def gen_report(%{
        "org_id" => org_id,
        "start_date" => start_date,
        "end_date" => end_date,
        "type" => type,
        "group_action" => group_action
      }) do
    end_date = end_date |> string_to_date()
    start_date = start_date |> string_to_date()
    Reports.range_report(org_id, start_date, end_date, type, group_action)
  end

  defp string_to_date(date) do
    date |> Timex.parse!("{YYYY}-{0M}-{D}") |> Timex.to_date()
  end
end
