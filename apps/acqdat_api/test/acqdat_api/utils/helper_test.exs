defmodule AcqdatApi.Utils.HelperTest do
  use ExUnit.Case, async: true

  describe "Date conversion" do
    test "Error - When argument not passed correctly" do
      {:error, :invalid_date} == AcqdatApi.Utils.Helper.string_to_date("2010-20-32")
      {:error, :invalid_date} == AcqdatApi.Utils.Helper.string_to_date("10-20-2021")
      {:error, :invalid_date} == AcqdatApi.Utils.Helper.string_to_date("21-2020-11")
    end

    test "Success - convert string date type to DateTime type" do
      assert ~D[2021-10-21] == AcqdatApi.Utils.Helper.string_to_date("2021-10-21")
      assert ~D[1992-12-25] == AcqdatApi.Utils.Helper.string_to_date("1992-12-25")
    end
  end
end
