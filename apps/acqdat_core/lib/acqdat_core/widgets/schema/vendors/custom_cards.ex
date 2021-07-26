defmodule AcqdatCore.Widgets.Schema.Vendors.CustomCards do
  @moduledoc """
    Embedded Schema of the settings of the widget with it keys and subkeys
  """

  # @data_types ~w(string color object list integer boolean)a

  defstruct card: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                type: %{data_type: :string, default_value: "", user_controlled: false},
                backgroundColor: %{
                  data_type: :color,
                  default_value: "#ffffff",
                  user_controlled: true
                },
                fontColor: %{data_type: :color, default_value: "#ffffff", user_controlled: true}
              }
            },
            title: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :string, default_value: "", user_controlled: true},
                align: %{
                  data_type: :select,
                  default_value: ["left", "right", "center", "top", "bottom"],
                  user_controlled: true
                },
                fontSize: %{data_type: :string, default_value: "14px", user_controlled: true},
                fontColor: %{data_type: :color, default_value: "#ffffff", user_controlled: true}
              }
            },
            unit: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :string, default_value: "", user_controlled: true},
                align: %{
                  data_type: :select,
                  default_value: ["left", "right", "center", "top", "bottom"],
                  user_controlled: true
                }
              }
            },
            image: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                url: %{data_type: :file, default_value: "", user_controlled: true},
                align: %{
                  data_type: :select,
                  default_value: ["left", "right", "center", "top", "bottom"],
                  user_controlled: true
                }
              }
            },
            percentage_bar: %{
              data_type: :list,
              user_controlled: false,
              properties: %{
                max: %{data_type: :integer, default_value: 0, user_controlled: false}
              }
            },
            description: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :text, default_value: "", user_controlled: true},
                align: %{
                  data_type: :select,
                  default_value: ["left", "right", "center", "top", "bottom"],
                  user_controlled: true
                },
                fontSize: %{data_type: :string, default_value: "14px", user_controlled: true},
                fontColor: %{data_type: :color, default_value: "#ffffff", user_controlled: true}
              }
            },
            subtitle: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :string, default_value: "", user_controlled: true},
                align: %{
                  data_type: :select,
                  default_value: ["left", "right", "center", "top", "bottom"],
                  user_controlled: true
                },
                fontSize: %{data_type: :string, default_value: "14px", user_controlled: true},
                fontColor: %{data_type: :color, default_value: "#ffffff", user_controlled: true}
              }
            },
            series: %{
              data_type: :list,
              user_defined: false,
              properties: %{}
            }
end
