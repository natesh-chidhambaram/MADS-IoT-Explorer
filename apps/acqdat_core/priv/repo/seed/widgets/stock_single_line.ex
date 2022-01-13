defmodule AcqdatCore.Seed.Widgets.StockSingleLine do
  @moduledoc """
  Holds seeds for Line widgets.
  """
  use AcqdatCore.Seed.Helpers.HighchartsUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  @highchart_key_widget_settings %{
    line: %{
      visual: %{
        chart: [type: %{value: "line"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}, style: [color: %{value: "#495057"}, fontSize: %{value: "15px"}]],
        caption: [text: %{}, align: %{}],
        subtitle: [text: %{}, align: %{}, style: [color: %{value: "#74788d"}, fontSize: %{value: "14px"}]],
        yAxis: [title: [text: %{}],
                plotBands: %{
                  data_type: :list,
                  value: [
                    %{color: "#55BF3B", from: 0, to: 120},
                    %{color: "#DDDF0D", from: 120, to: 160},
                    %{color: "#DF5353", from: 160, to: 200}
                  ],
                  properties: %{
                    color: %{data_type: :color, value: "#55BF3B", properties: %{}},
                    from: %{data_type: :integer, value: 0, properties: %{}},
                    to: %{data_type: :integer, value: 120, properties: %{}}
                  }
                }
              ],
        xAxis: [type: %{value: "datetime"}, title: [text: %{value: "Date"}],
                plotBands: %{
                  data_type: :list,
                  value: [
                    %{color: "#55BF3B", from: 0, to: 120},
                    %{color: "#DDDF0D", from: 120, to: 160},
                    %{color: "#DF5353", from: 160, to: 200}
                  ],
                  properties: %{
                    color: %{data_type: :color, value: "#55BF3B", properties: %{}},
                    from: %{data_type: :integer, value: 0, properties: %{}},
                    to: %{data_type: :integer, value: 120, properties: %{}}
                  }
                }
              ],
        rangeSelector: [selected: %{value: 1}],
        credits: [enabled: %{value: false}],
        legend: [enabled: %{value: true}]
      },
      data: %{
        series: %{
          data_type: :object,
          value: %{},
          properties: %{
            name: %{data_type: :string, value: %{}, properties: %{}},
            color: %{data_type: :color, value: %{data: "#000000"}, properties: %{}},
            multiple: %{data_type: :boolean, value: %{data: false}, properties: %{}}
          }
        },
        axes: %{
          data_type: :object,
          value: %{},
          properties: %{
            multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}},
            x: %{data_type: :list, value: %{}, properties: %{}},
            y: %{data_type: :list, value: %{}, properties: %{}}
          }
        }
      }
    }
  }

  @high_chart_value_settings %{
    line: %{
      visual_setting_values: %{
        title: %{text: "AAPL Stock Price"},
        rangeSelector: %{selected: 1}
      },
      data_settings_values: %{
        series: [
          %{
            name: "AAPL",
            data: [
              %{x: 1533735000000, y: 207.25},
              %{x: 1533821400000, y: 208.88},
              %{x: 1533907800000, y: 207.53},
              %{x: 1534167000000, y: 208.87},
              %{x: 1534253400000, y: 209.75},
              %{x: 1534339800000, y: 210.24},
              %{x: 1534426200000, y: 213.32}
            ]
          }
        ]
      }
    }
  }

  def seed() do
    widget_type = WidgetHelpers.find_or_create_widget_type("HighCharts")
    seed_widgets(widget_type)
  end

  def seed_widgets(widget_type) do
    @highchart_key_widget_settings
    |> Enum.map(fn {key, widget_settings} ->
      set_widget_data(key, widget_settings, @high_chart_value_settings[key],
        widget_type)
    end)
    |> Enum.each(fn data ->
      Repo.insert!(data)
    end)
  end

  def set_widget_data(_key, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "Stock Single line series",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      image_url: "https://mads-image.s3.ap-southeast-1.amazonaws.com/widgets/stock-single-line.png",
      category: ["stock_chart", "line"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end

end
