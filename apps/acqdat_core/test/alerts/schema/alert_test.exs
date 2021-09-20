defmodule AcqdatCore.Alerts.Schema.AlertTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Alerts.Schema.Alert

  describe "changeset/2" do
    test "returns a valid changeset" do
      project = insert(:project)

      params = %{
        name: "Test name",
        description: "Test description",
        alert_policy_meta: %{},
        entity_name: "Gateway",
        entity_uuid: "abc2345",
        communication_medium: ["e-mail", "sms"],
        recipient_ids: [%{type: "user", id: 1}, %{type: "user", id: 2}, %{type: "user", id: 3}],
        org_id: project.org_id,
        project_id: project.id,
        app: "iot_manager",
        grouping_hash: "",
        severity: "Low",
        status: "resolved",
        alert_events_log: [],
        alert_meta: %{},
        grouping_meta: %{
          module: "Elixir.AcqdatCore.Alerts.Schema.Grouping.TimeGrouping",
          grouping_parameters: %{
            value: 1,
            unit: "minutes",
            previous_time: Timex.now()
          }
        }
      }

      %{valid?: validity} = changeset = Alert.changeset(%Alert{}, params)
      assert validity
    end

    test "returns invalid if one or more required fields are missing" do
      params = %{
        name: "Test name",
        description: "Test description",
        app: "iot_manager",
        entity_name: "Gateway",
        entity_uuid: "abc2345",
        communication_medium: ["e-mail", "sms"],
        recepient_ids: [%{type: "user", id: 1}, %{type: "user", id: 2}],
        severity: "Low"
      }

      %{valid?: validity} = changeset = Alert.changeset(%Alert{}, params)

      assert errors_on(changeset) ==
               %{org_id: ["can't be blank"], status: ["can't be blank"]}
    end
  end
end
