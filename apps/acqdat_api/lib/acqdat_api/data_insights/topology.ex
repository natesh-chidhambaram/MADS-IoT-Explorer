defmodule AcqdatApi.DataInsights.Topology do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatApiWeb.DataInsights.TopologyEtsConfig
  alias AcqdatApi.DataInsights.FactTableGenWorker
  alias NaryTree
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Schema.EntityManagement.{Asset, Sensor}
  alias AcqdatCore.Domain.EntityManagement.SensorData
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Repo
  import Ecto.Query
  alias Ecto.Multi
  alias AcqdatApi.DataInsights.FactTables, as: FactTablesCon

  def entities(data) do
    sensor_types = SensorTypeModel.get_all(data)
    asset_types = AssetTypeModel.get_all(data)
    %{topology: %{sensor_types: sensor_types || [], asset_types: asset_types || []}}
  end

  @doc """
  Creates a topology for the provided project.

  The functions parses the project tree and generates a hierarchy tree based on
  asset types and sensor types. The tree depicts a compressed view of the actual
  asset tree of a project in which all the assets at the same level, under a single
  parent are grouped within a single node based on the asset type. Similarly all the
  sensors under an asset are grouped together based on their sensory type within a
  node and placed as a child of the parent.

  The function then caches the generated tree in an ets table for fast access.
  In case the tree is already present in the cache the same is returned.

  #TODO: project version should also be stored in the cache, in case the project
  version has changed the tree in the cache should be updated.
  """
  def gen_topology(org_id, project) do
    proj_key = project |> ets_proj_key()
    data = proj_key |> TopologyEtsConfig.get()

    if data != [] do
      [{_, tree}] = data
      tree
    else
      topology_map = ProjectModel.gen_topology(org_id, project)
      TopologyEtsConfig.set(proj_key, topology_map)
    end
  end

  @doc """
  Generates the pre-requisites required to analyse the user provided entity list
  for a fact table.

  To create a fact table, the user provides a list of asset types and/or sensor
  types. The function separates the provided list into two based on their type
  `AssetType` or `SensorType`.

  It also returns the project topology tree in the form of an N-Ary tree so
  it can be used for further processing.

  It returns a map with the following keys:
  - `parsed_items`: A tuple containging list of asset and sensor types.
  - `parent_tree`: The project topology in the form of an N-Ary tree
  """
  def gen_fact_table_meta(entities_list, org_id, project) do
    result = Enum.reduce(entities_list, {[], []}, fn entity, {acc1, acc2} ->
      acc1 = if entity["type"] == "AssetType", do: acc1 ++ [entity], else: acc1
      acc2 = if entity["type"] == "SensorType", do: acc2 ++ [entity], else: acc2
      {acc1, acc2}
    end)

    topology_map = gen_topology(org_id, project)
    %{parsed_items: result, parent_tree: NaryTree.from_map(topology_map)}
  end

  @doc """
  Validates the user provided entity list and assigns it a `case`(explained below).

  The user provided entity list for a fact table generation falls into different
  `cases`:
  - `single sensor type`
  - `single asset type`
  - `multiple sensor type`
  - `multiple asset types`
  - `multiple asset types and multiple sensor types`

  The cases are explained below

  ### Single Sensor Type
  The user provides only a single sensor type, in this case, a fact table
  is created with data for all the sensors under that sensor type.

  ### Single Asset Type
  The user provides only a single asset type, in this case, a fact table
  is created only with data for assets under that asset type.

  ### Multiple Sensor Type
  In this case the user provides only different sensor types in the list. The
  following case cannot generate a fact table as sensor types represent the properties
  of an asset and if a common parent asset type is not present in the user provided
  list then it makes no sense to analyse this data. However, if the provided sensor
  types list contains multiple sensor types which are same with different metadata
  then a fact table is created with different metadata for the same sensor type.

  ### Multiple Asset Types
  In this case the user provides different asset types in the list. In this
  case it is evaluated if the asset types form a tree with one of the asset type
  as the root of the tree. In case they don't form a tree then this case can not
  be analysed and an error is returned.

  ### Multiple Asset Types and Sensor Types
  In this case the user provides different asset types alongwith sensor types in
  the list. In this case it is evaluated if the asset types and sensor types form a
  tree with one of the asset type as the root of the tree. In case they don't form
  a tree then this case can not be analysed and an error is returned.
  """

  def validate_entity_list(fact_table_id, {[], sensor_types}, _, _parent_tree)
      when length(sensor_types) == 1
    do
      {:ok, %{type: :single_sensor_type}}
  end

  def validate_entity_list(fact_table_id, {asset_types, []}, _, _parent_tree)
      when length(asset_types) == 1
    do
      {:ok, %{type: :single_asset_type}}
  end

  def validate_entity_list(fact_table_id, {[], sensor_types}, _, _parent_tree) do

    uniq_sensor_types = Enum.uniq_by(sensor_types, fn
        sensor_type -> sensor_type["id"]
    end)

    if length(uniq_sensor_types) == 1 do
      {:ok, %{type: :multiple_sensor_type}}
    else
      {
        :error,
        "Please attach parent asset_type as all the user-entities are of SensorTypes."
      }
    end
  end

  def validate_entity_list(fact_table_id, {asset_types, []}, _, _parent_tree) do
    uniq_asset_types = Enum.uniq_by(asset_types, fn asset_type -> asset_type["id"] end)

    if length(uniq_asset_types) == 1 do
      {:ok, %{type: :multiple_asset_types}}
    else

    end
  end

  def validate_entity_list(fact_table_id, {asset_types, sensor_types}, _, _parent_tree) do
    {:ok , %{type: :multiple_asset_and_sensor_types}}
  end

  # NOTE: 1. gen_sub_topology will update fact_table with user provided inputs
  #       2. It'll pass user input to parse_entities
  def gen_sub_topology(id, org_id, project, name, fact_table, entities_list, date_range_settings) do
    Multi.new()
    |> Multi.run(:update_to_db, fn _, _changes ->
      FactTables.update(fact_table, %{
        name: name,
        columns_metadata: entities_list,
        date_range_settings: date_range_settings
      })
    end)
    |> Multi.run(:gen_sub_topology, fn _, %{update_to_db: fact_table} ->
      parse_entities(id, entities_list, org_id, project)
      {:ok, "You'll receive fact table data on channel"}
    end)
    |> run_under_transaction(:gen_sub_topology)
  end

  # NOTE: 1. parse_entities will seperate asset_type_list and sensor_type_list
  #       2. It'll create parent tree from the map stores in ETS table
  #       3. It'll pass the flow to validate_entities
  defp parse_entities(id, entities_list, org_id, project) do
    res =
      Enum.reduce(entities_list, {[], []}, fn entity, {acc1, acc2} ->
        acc1 = if entity["type"] == "AssetType", do: acc1 ++ [entity], else: acc1
        acc2 = if entity["type"] == "SensorType", do: acc2 ++ [entity], else: acc2
        {acc1, acc2}
      end)

    topology_map = gen_topology(org_id, project)
    parent_tree = NaryTree.from_map(topology_map)

    validate_entities(id, res, entities_list, parent_tree)
  end

  # NOTE: 1. execute_descendants will start a Genserver, which will do the asynchronous computation
  #          of subtree generation + subree validations + dynamic query building + fact table gen
  def execute_descendants(id, parent_tree, root_node, entities_list, node_tracker) do
    FactTableGenWorker.process({id, parent_tree, root_node, entities_list, node_tracker})
  end

  # NOTE: this validate_entities will get executed if there is only one sensor_type is present in user input
  defp validate_entities(fact_table_id, {_, sensor_types}, entities_list, _)
       when length(sensor_types) == 1 and length(sensor_types) == length(entities_list) do
    [%{"id" => id, "name" => name, "metadata_name" => metadata_name}] = sensor_types

    output =
      if metadata_name == "name" do
        query =
          from(sensor in Sensor,
            where: sensor.sensor_type_id == ^id,
            select: [sensor.name]
          )

        %{headers: ["#{name}"], data: Repo.all(query)}
      else
        [%{"date_from" => date_from, "date_to" => date_to}] = sensor_types

        sensor_ids =
          from(sensor in Sensor,
            where: sensor.sensor_type_id == ^id,
            select: sensor.id
          )
          |> Repo.all()

        date_from = from_unix(date_from)
        date_to = from_unix(date_to)

        query = SensorData.filter_by_date_query_wrt_parent(sensor_ids, date_from, date_to)
        query = SensorData.fetch_sensors_values_n_timeseries(query, [metadata_name])

        %{
          headers: ["#{name}_#{metadata_name}", "#{name}_#{metadata_name}_dateTime"],
          data: Repo.all(query)
        }
      end

    headers = output[:headers] |> Enum.map_join(",", &"\"#{&1}\"")

    output =
      if output[:data] != [] do
        data = FactTablesCon.convert_table_data_to_text(output[:data])

        fact_table_name = "fact_table_#{fact_table_id}"

        FactTablesCon.create_fact_table_view(fact_table_name, headers, data)

        data = Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [])

        %{
          headers: data.columns,
          data: data.rows,
          total: FactTablesCon.total_no_of_rec(fact_table_name)
        }
      else
        %{error: "no data present"}
      end

    broadcast_to_channel(fact_table_id, output)
  end

  # NOTE: this validate_entities will get executed if there is only one asset_type is present in user input
  defp validate_entities(fact_table_id, {asset_types, _}, entities_list, _)
       when length(asset_types) == 1 and length(asset_types) == length(entities_list) do
    [%{"id" => id, "name" => name, "metadata_name" => metadata_name}] = asset_types

    {headers, data} =
      if metadata_name == "name" do
        data1 =
          from(asset in Asset,
            where: asset.asset_type_id == ^id,
            select: [asset.name]
          )
          |> Repo.all()

        headers = "name"
        {headers, data1}
      else
        data1 =
          from(asset in Asset,
            where: asset.asset_type_id == ^id,
            cross_join: c in fragment("unnest(?)", asset.metadata),
            where: fragment("?->>'name'", c) in ^[metadata_name],
            select: [
              asset.name,
              fragment("?->>'value'", c)
            ]
          )
          |> Repo.all()

        headers = (["name"] ++ [metadata_name]) |> Enum.map_join(",", &"\"#{&1}\"")
        {headers, data1}
      end

    output =
      if data != [] do
        data = FactTablesCon.convert_table_data_to_text(data)

        fact_table_name = "fact_table_#{fact_table_id}"

        FactTablesCon.create_fact_table_view(fact_table_name, headers, data)

        data = Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [])

        %{
          headers: data.columns,
          data: data.rows,
          total: FactTablesCon.total_no_of_rec(fact_table_name)
        }
      else
        %{error: "no data present"}
      end

    broadcast_to_channel(fact_table_id, output)
  end

  # NOTE: this validate_entities will get executed if there are multiple only sensor_types present in user input
  defp validate_entities(fact_table_id, {_, sensor_types}, entities_list, _)
       when length(sensor_types) == length(entities_list) do
    uniq_sensor_types = Enum.uniq_by(sensor_types, fn sensor_type -> sensor_type["id"] end)

    output =
      if length(uniq_sensor_types) == 1 do
        FactTableGenWorker.process({fact_table_id, entities_list, uniq_sensor_types})
      else
        output =
          {:error, "Please attach parent asset_type as all the user-entities are of SensorTypes."}

        broadcast_to_channel(fact_table_id, output)
      end
  end

  # NOTE: this validate_entities will get executed if there are multiple only asset_types present in user input
  defp validate_entities(fact_table_id, {asset_types, _sensor_types}, entities_list, parent_tree)
       when length(asset_types) == length(entities_list) do
    uniq_asset_types = Enum.uniq_by(asset_types, fn asset_type -> asset_type["id"] end)

    if length(uniq_asset_types) == 1 do
      [%{"id" => asset_type_id} | _] = uniq_asset_types
      metadata_list = Enum.map(asset_types, fn asset_type -> asset_type["metadata_name"] end)
      res = AssetModel.fetch_asset_metadata(asset_type_id, metadata_list)

      data =
        Enum.group_by(res, fn x -> x.name end, fn y -> %{"#{y.metadata_name}" => y.value} end)

      [first_metadata | _] = Map.values(data)

      data =
        Enum.reduce(data, [], fn {key, metadatas}, acc1 ->
          acc1 ++
            [[key] ++ List.flatten(Enum.map(metadatas, fn metadata -> Map.values(metadata) end))]
        end)

      output =
        if data != [] do
          headers =
            (["name"] ++ List.flatten(Enum.map(first_metadata, fn x -> Map.keys(x) end)))
            |> Enum.map_join(",", &"\"#{&1}\"")

          data = FactTablesCon.convert_table_data_to_text(data)

          fact_table_name = "fact_table_#{fact_table_id}"

          FactTablesCon.create_fact_table_view(fact_table_name, headers, data)

          data = Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [])

          %{
            headers: data.columns,
            data: data.rows,
            total: FactTablesCon.total_no_of_rec(fact_table_name)
          }
        else
          %{error: "no data present"}
        end

      broadcast_to_channel(fact_table_id, output)
    else
      {entity_levels, {root_node, root_entity}, entity_map} =
        Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
          node = NaryTree.get(parent_tree, "#{entity["id"]}")
          acc1 = acc1 ++ [node.level]

          {acc2, acc4} =
            if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

          acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
          {acc1, {acc2, acc4}, acc3}
        end)

      if length(Enum.uniq(entity_levels)) == 1 do
        output =
          {:error,
           "All the asset_type entities are at the same level, Please attach common parent entity."}

        broadcast_to_channel(fact_table_id, output)
      else
        node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

        execute_descendants(fact_table_id, parent_tree, root_node, entities_list, node_tracker)
      end
    end
  end

  # NOTE: 1. this validate_entities will find root elem of the user provided input with the help of subtree
  #       2. this'll then call the Genserver flow for further fact_table processing
  defp validate_entities(id, {asset_types, sensor_types}, entities_list, parent_tree) do
    {entity_levels, {root_node, root_entity}, entity_map} =
      Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
        node = NaryTree.get(parent_tree, "#{entity["id"]}")
        acc1 = acc1 ++ [node.level]

        {acc2, acc4} =
          if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

        acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
        {acc1, {acc2, acc4}, acc3}
      end)

    node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

    execute_descendants(id, parent_tree, root_node, entities_list, node_tracker)
  end

  defp broadcast_to_channel(fact_table_id, output) do
    AcqdatApiWeb.Endpoint.broadcast("project_fact_table:#{fact_table_id}", "out_put_res", %{
      data: output
    })
  end

  defp ets_proj_key(project) do
    "#{project.id}_#{project.version}"
  end

  defp from_unix(datetime) do
    {datetime, _} = Integer.parse(datetime)
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end

  defp run_under_transaction(multi, result_key) do
    multi
    |> Repo.transaction(timeout: :infinity)
    |> case do
      {:ok, result} ->
        {:ok, result[:del_rec_frm_fact_tab]}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end
end
