defmodule AcqdatCore.Alerts.Model.AlertTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  alias AcqdatCore.Alerts.Model.Alert, as: AlertModel

  @valid_params %{
    name: "Test name",
    description: "Test description",
    policy_module_name: "Elixir.AcqdatCore.Alerts.Policies.RangeBased",
    policy_name: "Alert when data is outside a bounded range",
    app: "iot_manager",
    entity_name: "Gateway",
    entity_id: 1,
    communication_medium: ["email", "sms"],
    recepient_ids: [1, 2, 3],
    severity: "Low",
    status: "resolved",
    creator_id: 1,
    org_id: 1,
    rule_parameters: [
      %{
        name: "temperature",
        data_type: "float",
        entity_parameter_uuid: "abc",
        entity_parameter_name: "temperature",
        value: 34
      },
      %{
        name: "humidity",
        data_type: "float",
        entity_parameter_uuid: "abc",
        entity_parameter_name: "temperature",
        value: 34
      }
    ]
  }

  describe "create/1" do
    test "with valid params" do
      valid_params = @valid_params

      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 0

      {:ok, _} = AlertModel.create(valid_params)

      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 1

      first_alert = alerts.entries |> List.first()
      assert first_alert.name == valid_params[:name]
      assert first_alert.description == valid_params[:description]
    end

    test "with invalid params" do
      invalid_params = %{name: "Test name"}
      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 0

      {:error, _} = AlertModel.create(invalid_params)

      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 0
    end
  end

  describe "update/1" do
    setup do
      {:ok, alert} = AlertModel.create(@valid_params)

      [alert: alert]
    end

    test "with valid update params", %{alert: alert} do
      update_params = %{description: "Updated description"}

      previous_description = alert.description

      {:ok, _alert} = AlertModel.update(alert, update_params)

      {:ok, updated_alert} = AlertModel.get_by_id(alert.id)
      refute updated_alert.description == previous_description
      assert updated_alert.description == update_params[:description]
    end

    test "with invalid update params", %{alert: alert} do
      invalid_params = %{creator_id: nil}

      previous_creator_id = alert.creator_id

      {:error, _} = AlertModel.update(alert, invalid_params)

      {:ok, updated_alert} = AlertModel.get_by_id(alert.id)
      refute updated_alert.creator_id == invalid_params[:creator_id]
      assert updated_alert.creator_id == previous_creator_id
    end
  end

  describe "delete/1" do
    setup do
      {:ok, alert} = AlertModel.create(@valid_params)
      [alert: alert]
    end

    test "with valid params", %{alert: alert} do
      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 1

      {:ok, _} = AlertModel.delete(alert)

      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 0
    end
  end

  describe "get_all/1" do
    setup do
      {:ok, alert} = AlertModel.create(@valid_params)

      [alert: alert]
    end

    test "with valid params", %{alert: _} do
      valid_params = @valid_params

      alerts = AlertModel.get_all(%{page_size: 1, page_number: 0})
      assert alerts.total_entries == 1

      first_alert = alerts.entries |> List.first()
      assert first_alert.name == valid_params[:name]
      assert first_alert.description == valid_params[:description]
    end
  end

  describe "get_by_id/1" do
    setup do
      {:ok, alert} = AlertModel.create(@valid_params)

      [alert: alert]
    end

    test "with valid id", %{alert: alert} do
      valid_params = @valid_params

      {:ok, first_alert} = AlertModel.get_by_id(alert.id)

      assert first_alert.name == valid_params[:name]
      assert first_alert.description == valid_params[:description]
    end

    test "with invalid id", %{alert: _} do
      {state, message} = AlertModel.get_by_id(12132)

      assert state == :error
      assert message == "Alert not found"
    end
  end
end
