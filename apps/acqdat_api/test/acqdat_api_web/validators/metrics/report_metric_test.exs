defmodule AcqdatApiWeb.Validators.Metrics.ReportMetricTest do
  use ExUnit.Case
  alias AcqdatApiWeb.Validators.Metrics.ReportMetric

  describe "validate parameters with app and entity" do
    setup [:params_with_app]

    test "success - when data provided correctly", %{params: params} do
      assert {:ok, _data} = ReportMetric.validate_params(params)
      assert {:ok, _data} = ReportMetric.validate_params(%{params | "group_action" => "monthly"})
      assert {:ok, _data} = ReportMetric.validate_params(%{params | "type" => "cards"})
      assert {:ok, _data} = ReportMetric.validate_params(%{params | "app" => "new app"})
    end

    test "error - when data is not correct", %{params: params} do
      refute :ok == ReportMetric.validate_params(%{params | "group_action" => "half"})

      assert {:validation_error, _error} =
               ReportMetric.validate_params(%{params | "group_action" => "half"})

      assert {:validation_error, _error} =
               ReportMetric.validate_params(%{params | "type" => "painting"})

      assert {:validation_error, _error} =
               ReportMetric.validate_params(%{params | "end_date" => "2020-08-02"})
    end
  end

  describe "validate parameters without app and entity" do
    setup [:params_without_app]

    test "success - when data provided correctly", %{params: params} do
      assert {:ok, _data} = ReportMetric.validate_params(params)
      assert {:ok, _data} = ReportMetric.validate_params(%{params | "group_action" => "monthly"})
      assert {:ok, _data} = ReportMetric.validate_params(%{params | "type" => "cards"})
      assert {:ok, _data} = ReportMetric.validate_params(%{params | "org_id" => "new org"})
    end

    test "error - when data is not correct", %{params: params} do
      assert {:validation_error, _error} =
               ReportMetric.validate_params(%{params | "group_action" => "half"})

      assert {:validation_error, _error} =
               ReportMetric.validate_params(%{params | "type" => "sketch"})

      assert {:validation_error, _error} =
               ReportMetric.validate_params(%{params | "end_date" => "2020-08-02"})
    end
  end

  def params_with_app(context) do
    params = %{
      "org_id" => "org123",
      "app" => "App name",
      "entity" => "entity",
      "end_date" => "2020-09-02",
      "group_action" => "weekly",
      "start_date" => "2020-08-02",
      "type" => "list"
    }

    {:ok, Map.put(context, :params, params)}
  end

  def params_without_app(context) do
    params = %{
      "org_id" => "org123",
      "end_date" => "2020-09-02",
      "group_action" => "weekly",
      "start_date" => "2020-08-02",
      "type" => "list"
    }

    {:ok, Map.put(context, :params, params)}
  end
end
