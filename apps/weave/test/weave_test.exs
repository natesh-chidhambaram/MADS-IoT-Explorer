defmodule WeaveTest do
  use ExUnit.Case
  doctest Weave

  test "greets the world" do
    assert Weave.hello() == :world
  end
end
