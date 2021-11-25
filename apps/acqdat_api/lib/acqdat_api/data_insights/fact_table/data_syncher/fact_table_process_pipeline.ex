defmodule AcqdatApi.DataInsights.FactTable.FactTableProcessPipeline do
  use Broadway
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DataInsights.FactTables
  alias AcqdatApiWeb.Helpers
  alias AcqdatApi.DataStructure.Trees.NaryTree
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Schema.EntityManagement.{Asset, AssetType}
  alias AcqdatApi.DataInsights.FactTables, as: FactTablesCon

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
        fact_tables: [concurrency: System.schedulers_online()]
      ]
    ]

    Broadway.start_link(__MODULE__, options)
  end

  def handle_message(_processor, message, _context) do
    data = Jason.decode!(message.data)

    message
    |> Broadway.Message.put_batcher(:fact_tables)
    |> Broadway.Message.put_batch_key("fact_tables:#{data["fact_tables_id"]}")
  end

  def handle_batch(_batcher, messages, batch_info, _context) do
    [_, fact_table_id] = String.split(batch_info.batch_key, ":")

    case FactTables.get_by_id(fact_table_id) do
      {:ok, fact_table} ->
        if fact_table.subtree != nil && fact_table.leaf_nodes != nil do
          subtree = Helpers.keys_to_atoms(fact_table.subtree)
          leaf_nodes = Helpers.keys_to_atoms(%{"leaf_nodes" => fact_table.leaf_nodes})

          res =
            messages
            |> Enum.reduce([], fn message, acc ->
              data = Jason.decode!(message.data)

              if is_leaf?(leaf_nodes.leaf_nodes, data) != [],
                do: row_computation(fact_table, data, subtree)

              acc = [data | acc]
            end)
        end

      {:error, error} ->
        {:error, error}
    end

    messages
  end

  # TODO: Refactor this function and move to fact_table domain module
  def row_computation(
        %{headers_metadata: headers_metadata, id: fact_table_id} = fact_table,
        event,
        subtree
      ) do
    row = List.duplicate(nil, headers_metadata["rows_len"])
    leaf_id = "#{event["entity_id"]}_#{event["entity_name"]}"

    row =
      if event["entity_source_name"] == "name" do
        leaf_pos = headers_metadata["headers"][leaf_id][event["entity_source_name"]]
        if leaf_pos, do: List.replace_at(row, leaf_pos, event["entity_source_val"]), else: row
      end

    row =
      if event["metadata"] do
        Enum.reduce(event["metadata"], row, fn metadata, acc ->
          pos = headers_metadata["headers"][leaf_id][metadata["uuid"]]
          acc = if pos, do: List.replace_at(acc, pos, metadata["value"]), else: acc
          tim_pos = headers_metadata["headers"][leaf_id]["#{metadata["uuid"]}_dateTime"]
          acc = if tim_pos, do: List.replace_at(acc, tim_pos, event["event_id"]), else: acc
          acc
        end)
      else
        if Enum.count(headers_metadata["headers"][leaf_id]) >= 2,
          do: List.duplicate(nil, headers_metadata["rows_len"]),
          else: row
      end

    if Enum.count(headers_metadata["headers"][leaf_id]) >= 2 && event["metadata"] == nil do
      row
    else
      subtree = NaryTree.from_map(subtree)
      leaf_node = NaryTree.get(subtree, leaf_id)

      {:ok, child} =
        if event["entity_type"] == "SensorType" do
          {:ok, sen} = AcqdatCore.Model.EntityManagement.Sensor.get(event["entity_source_id"])
        else
          {:ok, asset} = AcqdatCore.Model.EntityManagement.Asset.get(event["entity_source_id"])
        end

      row =
        if child && child.parent_id do
          {:ok, asset} = AssetModel.get(child.parent_id)

          subtree_computation(
            subtree,
            leaf_node,
            headers_metadata,
            row,
            asset,
            asset.asset_type_id,
            asset.asset_type.name
          )
        end

      if length(Enum.filter(row, &(!is_nil(&1)))) == 0,
        do: [],
        else: insert_to_fact_table(fact_table, row)
    end
  end

  # TODO: Refactor this function
  defp subtree_computation(subtree, tree_node, headers_metadata, row, asset, asset_type_id, name) do
    if tree_node.parent == "#{asset_type_id}_#{name}" do
      index_metadata = headers_metadata["headers"]["#{asset_type_id}_#{name}"]

      res =
        Enum.reduce(index_metadata, row, fn {key, idx_pos}, acc ->
          if key == "name" do
            List.replace_at(row, idx_pos, asset.name)
          else
            [%{value: metadata_val}] =
              Enum.filter(asset.metadata, fn metadata -> metadata.uuid == key end)

            List.replace_at(row, idx_pos, metadata_val)
          end
        end)

      parent_asset = AsNestedSet.ancestors(asset) |> AsNestedSet.execute(Repo)

      if parent_asset == [] do
        res
      else
        [asset] = parent_asset
        asset = asset |> Repo.preload([:asset_type])

        node = NaryTree.get(subtree, tree_node.parent)

        subtree_computation(
          subtree,
          node,
          headers_metadata,
          res,
          asset,
          asset.asset_type_id,
          asset.asset_type.name
        )
      end
    else
      if tree_node.parent == :empty do
        row
      else
        "need to perform"
      end
    end
  end

  defp insert_to_fact_table(
         %{
           id: fact_table_id,
           headers_metadata: headers_metadata,
           columns_metadata: columns_metadata
         },
         row
       ) do
    fact_table_name = "fact_table_#{fact_table_id}"
    headers_metadata = FactTablesCon.gen_fact_table_headers(columns_metadata, headers_metadata)
    tab_headers = List.flatten(Enum.map(headers_metadata, fn metadata -> Map.keys(metadata) end))

    tab_headers = tab_headers |> Enum.map_join(",", fn k -> "\"#{k}\"" end)
    row = row |> Enum.map_join(",", fn k -> "\'#{k}\'" end)

    qry = """
      INSERT INTO #{fact_table_name}
      (#{tab_headers})
      VALUES
      (#{row});
    """

    Ecto.Adapters.SQL.query!(Repo, qry, [])
  end

  defp is_leaf?(leaf_nodes, event) do
    Enum.filter(leaf_nodes, fn leaf ->
      leaf.id == "#{event["entity_id"]}_#{event["entity_name"]}"
    end)
  end
end
