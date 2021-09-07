defmodule Weave.Constant do
  def delay(duration \\ 1500) do
    :timer.sleep(duration)
  end
end
