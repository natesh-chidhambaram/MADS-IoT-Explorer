defmodule AcqdatApi.DataInsights.FactTable.FactTableProcessPipeline do
  use Broadway

  @producer BroadwayRabbitMQ.Producer
  @producer_config [
    queue: "fact_table_process_queue",
    declare: [durable: true],
    on_failure: :reject
  ]

  def start_link(_args) do
    options = [
      name: AcqdatApi.DataInsights.FactTable.FactTableProcessPipeline,
      producer: [module: {@producer, @producer_config}],
      processors: [
        default: []
      ],
      batchers: [
        fact_tables: [concurrency: System.schedulers_online() * 2]
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    data = Poison.decode!(message.data)

    message
    |> Broadway.Message.put_batcher(:fact_tables)
    |> Broadway.Message.put_batch_key("fact_tables:#{data["fact_tables_id"]}")
  end

  def handle_batch(batcher, messages, batch_info, _context) do
    # IO.puts("#{inspect(self())} Batch #{batch_info.batcher}
    # #{batch_info.batch_key}")
    IO.inspect("inside batch function of FactTableProcessPipeline")
    IO.inspect(batcher)
    IO.inspect(batch_info.batch_key)
    IO.inspect(messages)
    messages
  end
end
