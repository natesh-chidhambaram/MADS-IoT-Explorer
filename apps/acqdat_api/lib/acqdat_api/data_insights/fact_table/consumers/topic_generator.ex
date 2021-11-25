defmodule AcqdatApi.DataInsights.FactTable.Consumers.TopicGenerator do
  use GenServer
  use AMQP
  alias AcqdatCore.Model.DataInsights.FactTables
  alias AcqdatApi.DataInsights.FactTable.Consumers.DataSynching

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange "topic_generator"
  @queue "topic_generator"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)
    setup_queue(chan)

    # Limit unacknowledged messages to 10
    :ok = Basic.qos(chan, prefetch_count: 10)
    # Register the GenServer process as a consumer
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    IO.inspect(chan)
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

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    # You might want to run payload consumption in separate Tasks in production
    consume(chan, tag, redelivered, payload)
    {:noreply, chan}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: true)

    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    {:ok, _} =
      Queue.declare(chan, @queue,
        durable: true,
        arguments: [
          {"x-dead-letter-exchange", :longstr, ""},
          {"x-dead-letter-routing-key", :longstr, @queue_error}
        ]
      )

    :ok = Exchange.fanout(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
  end

  defp consume(channel, tag, redelivered, payload) do
    params = Poison.decode!(payload)
    # params = %{project_id: 6, entity_type: "SensorType", entity_id: "name"}
    fact_tables_ids = FactTables.fetch_fetch_tables_id_by_columns_metadata(params)

    DataSynching.start_link()
    {:ok, conn} = AMQP.Connection.open()
    {:ok, chan} = AMQP.Channel.open(conn)

    Enum.map(fact_tables_ids, fn fact_table_id ->
      AMQP.Basic.publish(chan, "data_synching1", "fact_tables.#{fact_table_id}", payload)
    end)

    # AMQP.Basic.publish chan, "data_synching1", "fact_tables.2", payload
    # AMQP.Basic.publish chan, "gen_server_test_exchange", "", "5"
    # IO.inspect(fact_tables_ids)
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
