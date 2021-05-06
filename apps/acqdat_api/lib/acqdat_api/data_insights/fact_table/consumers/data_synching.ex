defmodule AcqdatApi.DataInsights.FactTable.Consumers.DataSynching do
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange "data_synching1"
  @queue "data_synching"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)
    # setup_queue(chan)

    {:ok, %{queue: queue_name}} = Queue.declare(chan, "", exclusive: true)

    :ok = Exchange.declare(chan, @exchange, :topic)
    :ok = Queue.bind(chan, queue_name, @exchange, routing_key: "fact_tables.*")

    # Limit unacknowledged messages to 10
    :ok = Basic.qos(chan, prefetch_count: 10)
    # Register the GenServer process as a consumer
    {:ok, _consumer_tag} = Basic.consume(chan, queue_name)
    {:ok, chan}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info(
        {:basic_deliver, payload,
         %{delivery_tag: tag, redelivered: redelivered, routing_key: routing_key}},
        chan
      ) do
    # You might want to run payload consumption in separate Tasks in production
    consume(chan, tag, redelivered, payload, routing_key)
    {:noreply, chan}
  end

  defp setup_queue(chan) do
    # {:ok, _} = Queue.declare(chan, @queue_error, durable: true)

    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    # {:ok, _} =
    #   Queue.declare(chan, @queue)

    {:ok, %{queue: queue_name}} = Queue.declare(chan, "", exclusive: true)

    :ok = Exchange.declare(chan, @exchange, :topic)
    :ok = Queue.bind(chan, queue_name, @exchange, routing_key: "fact_tables.*")
  end

  defp consume(channel, tag, redelivered, payload, routing_key) do
    payload = Poison.decode!(payload)
    IO.inspect(payload)

    [_, fact_table_id] = String.split(routing_key, ".")

    IO.inspect(fact_table_id)
    :ok = Basic.ack(channel, tag)
  rescue
    # Requeue unless it's a redelivered message.
    # This means we will retry consuming a message once in case of exception
    # before we give up and have it moved to the error queue
    #
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise comsumer will stop
    # receiving messages.
    exception ->
      :ok = Basic.reject(channel, tag, requeue: not redelivered)
      IO.puts("Error on dealing with payload")
  end
end
