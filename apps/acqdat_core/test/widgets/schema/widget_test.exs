defmodule AcqdatCore.Widgets.Schema.WidgetTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Test.Support.WidgetData
  alias AcqdatCore.Widgets.Schema.Widget

  setup_all %{} do
    widget_params = WidgetData.data()
    [widget_params: widget_params]
  end

  describe "changeset/2 " do
    @tag timeout: :infinity
    test "returns a valid changeset", context do
      %{widget_params: params} = context
      %{valid?: valid} = Widget.changeset(%Widget{}, params)
      assert valid
    end
  end
end
