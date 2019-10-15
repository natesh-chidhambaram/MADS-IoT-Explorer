defmodule AcqdatCore.Model.SensorTypeTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.SensorType

  describe "get_all" do
    test "returns all the sensor types" do
      insert_list(3, :sensor_type)

      sensor_types = SensorType.get_all()
      assert length(sensor_types) == 3
    end
  end
end
