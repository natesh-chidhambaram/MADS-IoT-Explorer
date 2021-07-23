defmodule AcqdatApi.DataInsights.FactTable.DataSynchingPipeline do
  use Broadway
  alias AcqdatCore.Model.DataInsights.FactTables

  @producer BroadwayRabbitMQ.Producer
  @producer_config [
    queue: "data_sync_queue",
    declare: [durable: true],
    on_failure: :reject
  ]

  def start_link(_args) do
    options = [
      name: AcqdatApi.DataInsights.FactTable.DataSynchingPipeline,
      producer: [module: {@producer, @producer_config}],
      processors: [
        default: []
      ],
      batchers: [
        asset_type: [],
        sensor_type: []
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def prepare_messages(messages, _context) do
    IO.inspect(messages)

    Enum.map(messages, fn message ->
      params = Poison.decode!(message.data)

      # params = %{project_id: 1, entity_type: "SensorType", entity_id: "Building", metadata_id: "name"}
      fact_tables_ids = FactTables.fetch_fetch_tables_id_by_columns_metadata(params)

      Broadway.Message.update_data(message, fn data ->
        data = Poison.decode!(data)
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
        data = Poison.encode!(data)
        AMQP.Basic.publish(channel, "", "fact_table_process_queue", data)
      end)
    end)

    messages
  end
end
