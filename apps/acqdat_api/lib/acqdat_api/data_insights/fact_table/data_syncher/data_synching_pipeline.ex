defmodule AcqdatApi.DataInsights.FactTable.DataSynchingPipeline do
  use Broadway
  alias AcqdatCore.Model.DataInsights.FactTables

  @queue "data_sync_queue"
  @exchange "entity_exch"

  @producer BroadwayRabbitMQ.Producer

  def start_link(_args) do
    Broadway.start_link(__MODULE__,
      name: AcqdatApi.DataInsights.FactTable.DataSynchingPipeline,
      producer: [
        module:
          {@producer,
           queue: @queue,
           declare: [durable: true],
           after_connect: &declare_rabbitmq_topology/1,
           bindings: [{@exchange, []}],
           on_failure: :reject}
      ],
      processors: [
        default: []
      ],
      batchers: [
        asset_type: [],
        sensor_type: []
      ]
    )
  end

  def prepare_messages(messages, _context) do
    IO.inspect(messages)

    # TODO: Need to refactor, database lookup(bulk fetch)
    # 1. load all the fact_tables in the memory and perform computation(think about it)
    Enum.map(messages, fn message ->
      # TODO: using json
      params = Jason.decode!(message.data)
      IO.inspect("params")
      IO.inspect(params)

      # params = %{project_id: 1, entity_type: "SensorType", entity_id: "Building", metadata_id: "name"}
      fact_tables_ids = FactTables.fetch_fetch_tables_id_by_columns_metadata(params)

      Broadway.Message.update_data(message, fn data ->
        data = Jason.decode!(data)
        Map.put(data, "fact_tables_ids", fact_tables_ids)
      end)
    end)
  end

  def handle_message(_processor, message, _context) do
    case message do
      %{data: %{"entity_type" => "AssetType"}} = message ->
        Broadway.Message.put_batcher(message, :asset_type)

      %{data: %{"entity_type" => "SensorType"}} = message ->
        Broadway.Message.put_batcher(message, :sensor_type)

      message ->
        message
    end
  end

  def handle_batch(_batcher, messages, batch_info, _context) do
    messages
    |> Enum.each(fn message ->
      channel = message.metadata.amqp_channel

      Enum.each(message.data["fact_tables_ids"], fn fact_tables_id ->
        data = Map.put(message.data, "fact_tables_id", fact_tables_id)
        data = Jason.encode!(data)
        AMQP.Basic.publish(channel, "", "fact_table_process_queue", data)
      end)
    end)

    messages
  end

  defp declare_rabbitmq_topology(amqp_channel) do
    with :ok <- AMQP.Exchange.declare(amqp_channel, @exchange, :topic, durable: true),
         {:ok, _} <- AMQP.Queue.declare(amqp_channel, @queue, durable: true),
         :ok <- AMQP.Queue.bind(amqp_channel, @queue, @exchange, routing_key: "entity.*.*") do
      :ok
    end
  end
end
