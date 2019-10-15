defmodule AcqdatCore.Schema.SensorTypeTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  alias AcqdatCore.Schema.SensorType

  describe "changeset/2" do
    test "returns a valid changeset" do
      params = %{
        name: "temperature",
        make: "Adafruit",
        visualizer: "pie chart",
        identifier: "temperature",
        value_keys: ["temp"]
      }

      assert %{valid?: validity} = SensorType.changeset(%SensorType{}, params)
      assert validity
    end

    test "returns invalid if params missing" do
      %{valid?: validity} = changeset = SensorType.changeset(%SensorType{}, %{})

      refute validity

      assert %{
               identifier: ["can't be blank"],
               name: ["can't be blank"],
               value_keys: ["can't be blank"]
             } == errors_on(changeset)
    end
  end
end
