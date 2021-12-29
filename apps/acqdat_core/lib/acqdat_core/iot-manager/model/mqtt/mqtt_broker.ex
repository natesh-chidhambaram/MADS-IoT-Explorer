defmodule AcqdatCore.Model.IotManager.MQTTBroker do
  @moduledoc """
  Module exposes functions to work MQTT broker in IoT Manager App.
  """
  alias AcqdatCore.Model.IotManager.MQTT.Handler
  alias AcqdatCore.MQTT.Connection.Supervisor, as: MQTTSup
  require Logger

  # TODO log error if client dosen't start for some reason
  # TODO Add mox to handle all mqtt broker related mocks.
  def start_client(entity_uuid, subscription_topics, password) do
    [host: host, port: port] = Application.get_env(:acqdat_core, :mqtt_broker)

    case MQTTSup.start_child(
           client_id: entity_uuid,
           handler: {Handler, []},
           server: {Tortoise.Transport.Tcp, host: host, port: String.to_integer(port)},
           subscriptions: subscription_topics,
           user_name: entity_uuid,
           password: password
         ) do
      {:ok, result} ->
        {:ok, result}

      _ ->
        Logger.error("MQTT Client failed to start")
    end
  end

  def publish(client_id, topic, payload) do
    Tortoise.publish(
      client_id,
      topic,
      payload
    )
  end
end
