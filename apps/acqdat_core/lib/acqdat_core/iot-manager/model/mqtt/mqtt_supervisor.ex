defmodule AcqdatCore.MQTT.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      AcqdatCore.MQTT.Connection.Supervisor,
      AcqdatCore.MQTT.InititalizeServer
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end

defmodule AcqdatCore.MQTT.Connection.Supervisor do
  use DynamicSupervisor

  @doc """
  Start a dynamic supervisor that can hold connection processes.
  The `:name` option can also be given in order to register a supervisor
  name, the supported values are described in the "Name registration"
  section in the `GenServer` module docs.
  """
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Start a connection as a child of the `Tortoise.Supervisor`.
  `supervisor` is the name of the supervisor the child should be
  started on, and it defaults to `Tortoise.Supervisor`.
  """
  def start_child(supervisor \\ __MODULE__, opts) do
    spec = {Tortoise.Connection, opts}
    DynamicSupervisor.start_child(supervisor, spec)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule AcqdatCore.MQTT.InititalizeServer do
  use GenServer
  alias AcqdatCore.Model.IotManager.MQTTBroker
  alias AcqdatCore.Model.IotManager.MQTT.BrokerCredentials

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_init_arg) do
    {:ok, %{}, {:continue, :initialize_clients}}
  end

  def handle_continue(:initialize_clients, state) do
    initialize()
    {:noreply, state}
  end

  defp initialize() do
    result = BrokerCredentials.get_all("Server")

    if result == [] do
      setup_server_cred()
    else
      [creds | _] = result
      subscriptions = format_subscriptions(creds.subscriptions)
      MQTTBroker.start_client(creds.entity_uuid, subscriptions, creds.access_token)
    end
  end

  defp setup_server_cred() do
    entity_uuid = UUID.uuid1(:hex)
    access_token = UUID.uuid1(:hex)
    {:ok, creds} = BrokerCredentials.create(entity_uuid, access_token, "Server")
    subscriptions = format_subscriptions(creds.subscriptions)
    MQTTBroker.start_client(creds.entity_uuid, subscriptions, creds.access_token)
  end

  defp format_subscriptions(subscriptions) do
    Enum.map(subscriptions, fn data ->
      {data["topic"], data["qos"]}
    end)
  end
end
