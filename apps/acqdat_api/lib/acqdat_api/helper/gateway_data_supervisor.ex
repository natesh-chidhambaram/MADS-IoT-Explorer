defmodule AcqdatApi.Helper.GatewayDataSupervisor do
  use Supervisor

  alias AcqdatApi.Helper.GatewayDataActivity

  def init(_args) do
    project_uuids = AcqdatCore.Model.EntityManagement.Project.get_all_uuids()
    children = project_uuids |> Enum.map(&prepare_child_spec(&1))
    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec start_child(any) :: {:error, any} | {:ok, :undefined | pid} | {:ok, :undefined | pid, any}
  def start_child(project_uuid) do
    child_specification = prepare_child_spec(project_uuid)
    Supervisor.start_child(__MODULE__, child_specification)
  end

  def stop_child(project_uuid) do
    child_i = GatewayDataActivity.get_process_id(project_uuid)
    child_id = GenServer.whereis(child_i)
    IO.inspect(child_id, label: "child id ")
    # IO.inspect(Supervisor.which_children(__MODULE__))
    # IO.inspect  Supervisor.delete_child(__MODULE__, child_id)
    IO.inspect  Supervisor.terminate_child(__MODULE__, child_id)

  #  IO.inspect GenServer.stop(child_id)
  end

  def prepare_child_spec(project_uuid) do
    Supervisor.child_spec({GatewayDataActivity, project_uuid}, id: project_uuid)
  end
end
