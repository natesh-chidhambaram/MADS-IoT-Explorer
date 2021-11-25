defmodule AcqdatApi.DataStructure.Queues.Rabbitmq.Amqp do
  def publish_thr_exc(exchange, routing_key, params) do
    params = Jason.encode!(params)
    {:ok, connection} = AMQP.Connection.open(System.get_env("RABBITMQ_AMQP_URL"))
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.publish(channel, exchange, routing_key, params)
    AMQP.Connection.close(connection)
  end

  def publish(routing_key, params) do
    params = Jason.encode!(params)
    {:ok, connection} = AMQP.Connection.open(System.get_env("RABBITMQ_AMQP_URL"))
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Basic.publish(channel, "", routing_key, params)
    AMQP.Connection.close(connection)
  end
end
