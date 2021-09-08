defmodule AcqdatCore.Seed.Metrics.OrgMetric do
  alias AcqdatCore.Metrics.OrgMetrics
  alias AcqdatCore.Model.EntityManagement.Organisation
  alias AcqdatCore.Schema.Metrics
  alias AcqdatCore.Repo


  def seed() do
    {:ok, org} = Organisation.get(1)
    res = OrgMetrics.assimilate_all_metrics(org)

   Enum.map(0..30, &Timex.shift(DateTime.truncate(DateTime.utc_now(), :second), days: -&1))
    |> Enum.map(fn date_time ->
        Metrics.changeset(%Metrics{}, %{
            inserted_time: date_time,
            org_id: org.id,
            metrics: res
          }) |> Repo.insert!()
    end)
  end
end
