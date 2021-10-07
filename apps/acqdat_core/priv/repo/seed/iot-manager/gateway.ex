defmodule AcqdatCore.Seed.IoTManager.Gateway do
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Asset, Project}
  alias AcqdatCore.Repo
  import AcqdatApiWeb.Validators.IotManager.Gateway
  alias AcqdatApi.IotManager.Gateway, as: GModel
  alias AcqdatApiWeb.Helpers

  @gateway_params %{
    name: "Gateway1",
    access_token: "xyz1234asdf",
    parent_type: "Project",
    channel: "http",
    static_data: [],
    streaming_data: []
  }

  def seed_gateway() do
    [org] = Repo.all(Organisation)
    [project | _] = Repo.all(Project)

    params =
      @gateway_params
      |> Map.put(:org_id, org.id)
      |> Map.put(:project_id, project.id)
      |> Map.put(:parent_id, project.id)

    {:ok, data} =
      params
      |> verify_gateway()
      |> Helpers.extract_changeset_data()

    GModel.create(data)
  end

  def associate_sensor_and_gateways() do
    AcqdatCore.Model.IotManager.Gateway.associate_gateway_and_sensor()
  end
end
