defmodule AcqdatCoreTest do
  use ExUnit.Case
  doctest AcqdatCore

  test "greets the world" do
    assert AcqdatCore.hello() == :world
  end
end
