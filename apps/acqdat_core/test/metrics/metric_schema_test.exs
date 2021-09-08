defmodule AcqdatCore.Schema.MetricsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  alias AcqdatCore.Schema.Metrics
  alias AcqdatCore.Repo
  alias AcqdatCore.Metrics.{OrgMetrics, Reports}

  import AcqdatCore.Support.Factory

  describe "changeset" do
    test "returns a valid changeset" do
      params = dummy_data()

      changeset =
        Metrics.changeset(%Metrics{}, %{
          inserted_time: DateTime.truncate(DateTime.utc_now(), :second),
          org_id: 123,
          metrics: params
        })

      %{valid?: validity} = changeset
      assert validity
    end

    test "successfully updates database" do
      params = dummy_data()
      time = DateTime.truncate(DateTime.utc_now(), :second)

      changeset =
        Metrics.changeset(%Metrics{}, %{inserted_time: time, org_id: 123, metrics: params})

      Repo.insert!(changeset)
      data = Repo.all(Metrics)
      {:ok, test_meta} = Map.fetch(hd(data).metrics.dashboards.dashboards, "metadata")
      {:ok, test_data} = Map.fetch(test_meta, "data")
      {:ok, test_value} = Map.fetch(hd(test_data), "value")
      assert test_value == "Test Dashboard"
    end
  end

  describe "measure_and_dump" do
    test "successfully updates database with organisation info" do
      initial_size = Enum.count(Repo.all(Metrics))
      insert(:asset)
      insert(:asset)
      insert(:asset)
      OrgMetrics.measure_and_dump()
      final_size = Enum.count(Repo.all(Metrics))
      refute initial_size == final_size
    end
  end

  describe "range_report/5" do
    test "Rejects where data not available" do
      asset = insert(:asset)
      end_date = DateTime.to_date(DateTime.utc_now())
      start_date = Timex.beginning_of_month(end_date)

      {:error, message} =
        Reports.range_report(asset.org_id, start_date, end_date, "cards", "monthly")

      assert message == "Data missing for organisation on some days, cannot generate report"
    end

    test "Returns valid report for available data for cards" do
      asset = insert(:asset)
      org_id = asset.org_id
      sample = DateTime.utc_now()
      date = DateTime.to_date(sample)
      dummy = dummy_data()

      sum =
        Enum.reduce(1..30, 0, fn day, acc ->
          timestamp = sample |> Timex.shift(days: -day)
          random = Enum.random(0..50)
          newdashdash = %{dummy.dashboards.dashboards | count: random}
          newdash = %{dummy.dashboards | dashboards: newdashdash}
          newdata = %{dummy | dashboards: newdash}

          changeset =
            Metrics.changeset(%Metrics{}, %{
              inserted_time: timestamp,
              org_id: org_id,
              metrics: newdata
            })

          Repo.insert!(changeset)

          acc + random
        end)

      average = sum / 30
      start_date = Timex.shift(date, days: -30)
      {:ok, result} = Reports.range_report(org_id, start_date, date, "cards", "monthly")
      assert result.dashboard.dashboard_count == round(average)
    end
  end

  defp dummy_data() do
    %{
      dashboards: %{
        dashboards: %{
          count: 2,
          metadata: %{
            data: [
              %{id: 1, value: "Test Dashboard"},
              %{id: 2, value: "VSUN"}
            ]
          }
        },
        panels: %{
          count: 2,
          metadata: %{
            data: [
              %{id: 1, value: "Battery"},
              %{id: 2, value: "Home"}
            ]
          }
        },
        widgets: %{
          count: 4,
          metadata: %{
            data: [
              %{id: "e8986efa6f7211eba1760242ac1b000b", value: "Labelqwy8zoahffy8b5hma1fy"},
              %{id: "57fd2bd26f7311eb950b0242ac1b000b", value: "Labelfx7yeyca966re8o32y25"},
              %{id: "9d5101266f7411eb811a0242ac1b000b", value: "Label221qqg05qe62qedzvdrj"},
              %{id: "06ec901a702311eb8e0b0242ac1b000b", value: "Labelaphdwdzoz0rc597ezc8r"},
              %{id: "6e05f20a6c3611ebae140242ac1b000b", value: "Labelwewsxscf59m4xhgud4da"}
            ]
          }
        }
      },
      data_insights: %{
        fact_tables: %{count: 1, metadata: %{data: [%{id: 266, value: "AT1"}]}},
        visualisations: %{
          count: 2,
          metadata: %{data: [%{id: 63, value: "1"}, %{id: 64, value: "2"}]}
        }
      },
      entities: %{
        active_parameters: %{count: 0, metadata: []},
        asset_types: %{count: 1, metadata: %{data: [%{id: 44, value: "PowerCube"}]}},
        assets: %{
          count: 2,
          metadata: %{
            data: [%{id: "VSUN 5-30 V1", value: 195}, %{id: "Power Cube 10-100", value: 214}]
          }
        },
        gateways: %{
          count: 2,
          metadata: %{
            data: [
              %{id: "Gateway Cleantech 10-100", value: 47},
              %{id: "VSUN V1 5-30 Gateway", value: 28}
            ]
          }
        },
        projects: %{count: 1, metadata: %{data: [%{id: 70, value: "JTC Cleantech 1"}]}},
        sensor_types: %{
          count: 2,
          metadata: %{
            data: [%{id: 54, value: "PowerCubePramsV1"}, %{id: 51, value: "PowerCubeParams"}]
          }
        },
        sensors: %{
          count: 4,
          metadata: %{
            data: [
              %{id: "Power Cube Additional Params", value: 332},
              %{id: "VSUN Sensor V2", value: 339},
              %{id: "VSUN Sensor V1", value: 320},
              %{id: "Power Cube Main Params", value: 331}
            ]
          }
        }
      },
      role_manager: %{
        users: %{
          count: 0
        }
      }
    }
  end
end
