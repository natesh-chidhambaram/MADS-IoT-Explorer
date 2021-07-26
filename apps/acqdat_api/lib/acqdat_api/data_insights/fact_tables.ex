defmodule AcqdatApi.DataInsights.FactTables do
  import Ecto.Query
  alias AcqdatCore.Model.DataInsights.{FactTables, Visualizations}
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Schema.EntityManagement.{Asset, Sensor}
  alias AcqdatCore.Domain.EntityManagement.SensorData
  alias AcqdatCore.Repo
  alias AcqdatApi.DataStructure.Trees.NaryTree
  alias Ecto.Multi

  defdelegate get_fact_table_headers(fact_table_id), to: FactTables

  def get_all(%{project_id: project_id, org_id: org_id} = params) do
    data = FactTables.get_all(params)

    tot_visual_count =
      Visualizations.get_all_count_for_project(%{project_id: project_id, org_id: org_id})

    Map.merge(data, %{total_visualizations: tot_visual_count})
  end

  def fetch_fact_table_headers(%{id: fact_table_id} = fact_table) do
    headers =
      if fact_table.headers_metadata do
        gen_fact_table_headers(fact_table.columns_metadata, fact_table.headers_metadata)
      else
        get_fact_table_headers(fact_table_id)
      end

    Map.put(fact_table, :fact_table_headers, headers)
  end

  def delete(fact_table) do
    Multi.new()
    |> Multi.run(:del_rec_frm_fact_tab, fn _, _ ->
      FactTables.delete(fact_table)
    end)
    |> Multi.run(:del_temp_fact_tab, fn _, %{del_rec_frm_fact_tab: _} ->
      delete_temp_fact_table_view(fact_table)
    end)
    |> run_under_transaction(:del_rec_frm_fact_tab)
  end

  def create(org_id, %{name: project_name, id: project_id}, %{id: creator_id}) do
    res_name = :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
    fact_table_name = "#{project_name}_fact_table_#{res_name}"

    FactTables.create(%{
      name: fact_table_name,
      org_id: org_id,
      project_id: project_id,
      creator_id: creator_id
    })
  end

  def create(fact_table_name, org_id, %{name: _, id: project_id}, %{id: creator_id}) do
    FactTables.create(%{
      name: fact_table_name,
      org_id: org_id,
      project_id: project_id,
      creator_id: creator_id
    })
  end

  def fetch_name_by_id(%{"id" => id, "name" => name}) do
    fact_table_name = "fact_table_#{id}"

    qry = """
      select distinct "#{name}" from #{fact_table_name}
      where "#{name}" is not null and length("#{name}") > 0
      order by 1
    """

    res = Ecto.Adapters.SQL.query!(Repo, qry, [], timeout: :infinity)
    %{data: List.flatten(res.rows)}
  end

  def compute_sensors(fact_table_id, sensor_types, uniq_sensor_types) do
    [
      %{"id" => sensor_type_id, "date_from" => date_from, "date_to" => date_to, "name" => _}
      | _
    ] = uniq_sensor_types

    metadata_list = Enum.map(sensor_types, fn sensor_type -> sensor_type["metadata_name"] end)

    metadata_ids = Enum.map(sensor_types, fn sensor_type -> sensor_type["metadata_id"] end)

    sensor_ids =
      from(sensor in Sensor,
        where: sensor.sensor_type_id == ^sensor_type_id,
        select: sensor.id
      )
      |> Repo.all()

    date_from = from_unix(date_from)
    date_to = from_unix(date_to)

    query = SensorData.filter_by_date_query_wrt_parent(sensor_ids, date_from, date_to)
    data = SensorData.fetch_sensors_data(query, metadata_ids) |> Repo.all()

    rows_len = length(metadata_ids)

    res =
      Enum.reduce(data, [], fn entity, acc3 ->
        empty_row = List.duplicate(nil, rows_len + 1)
        indx_pos = Enum.find_index(metadata_list, fn x -> x == "name" end)

        computed_row =
          if indx_pos, do: List.replace_at(empty_row, indx_pos, entity.name), else: empty_row

        pos = Enum.find_index(metadata_list, fn x -> x == entity.param_name end)

        computed_row =
          if pos, do: List.replace_at(computed_row, pos, entity.value), else: computed_row

        computed_row =
          if entity.time,
            do: List.replace_at(computed_row, rows_len, entity.time),
            else: computed_row

        acc3 ++ [computed_row]
      end)

    headers = metadata_ids ++ ["entity_dateTime"]

    headers_metadata = %{
      "#{sensor_type_id}" =>
        Stream.with_index(headers, 0)
        |> Enum.reduce(%{}, fn {v, k}, acc ->
          Map.put(acc, v, k)
        end)
    }

    {:ok, fact_table} = FactTables.get_by_id(fact_table_id)

    {:ok, _} =
      FactTables.update(fact_table, %{
        headers_metadata: %{"rows_len" => length(headers), "headers" => headers_metadata}
      })

    headers =
      Enum.map(metadata_list, fn x ->
        if x == "name", do: %{"#{x}" => "text"}, else: %{"#{x}" => "numeric"}
      end) ++ [%{"entity_dateTime" => "timestamp"}]

    if res == [] do
      %{error: "No data present for the specified user inputs"}
    else
      fact_table_name = "fact_table_#{fact_table_id}"

      try do
        create_fact_table(fact_table_name, headers, res)

        data =
          Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [],
            timeout: :infinity
          )

        columns =
          Ecto.Adapters.SQL.query!(
            Repo,
            "select column_name, data_type from information_schema.columns where table_name = \'#{
              fact_table_name
            }\'",
            [],
            timeout: :infinity
          )

        columns = columns.rows |> Enum.map(fn [a, b] -> %{"#{a}" => b} end)

        %{headers: columns, data: data.rows, total: total_no_of_rec(fact_table_name)}
      rescue
        error in Postgrex.Error ->
          {:error, error.postgres.message}
      end
    end
  end

  def gen_comp_asset_metadata(%{
        fact_table_id: fact_table_id,
        uniq_asset_types: uniq_asset_types,
        asset_types: asset_types
      }) do
    [%{"id" => asset_type_id} | _] = uniq_asset_types
    metadata_list = Enum.map(asset_types, fn asset_type -> asset_type["metadata_id"] end)

    metadata_list_names = Enum.map(asset_types, fn asset_type -> asset_type["metadata_name"] end)

    metadata_list =
      if Enum.member?(metadata_list, "name"),
        do: ["name"] ++ (metadata_list -- ["name"]),
        else: ["name"] ++ metadata_list

    {metadata_list, metadata_list_names} =
      if Enum.member?(metadata_list, "name") do
        {["name"] ++ (metadata_list -- ["name"]), ["name"] ++ (metadata_list_names -- ["name"])}
      else
        {["name"] ++ metadata_list, ["name"] ++ metadata_list_names}
      end

    res = AssetModel.fetch_asset_metadata(asset_type_id, metadata_list)

    data = Enum.group_by(res, fn x -> x.name end, fn y -> %{"#{y.metadata_name}" => y.value} end)

    data =
      Enum.reduce(data, [], fn {key, metadatas}, acc1 ->
        acc1 ++
          [[key] ++ List.flatten(Enum.map(metadatas, fn metadata -> Map.values(metadata) end))]
      end)

    if data != [] do
      headers_metadata = %{
        "#{asset_type_id}" =>
          Stream.with_index(metadata_list, 0)
          |> Enum.reduce(%{}, fn {v, k}, acc ->
            Map.put(acc, v, k)
          end)
      }

      {:ok, fact_table} = FactTables.get_by_id(fact_table_id)

      {:ok, _} =
        FactTables.update(fact_table, %{
          headers_metadata: %{
            "rows_len" => length(metadata_list),
            "headers" => headers_metadata
          }
        })

      headers = Enum.map(metadata_list_names, fn x -> %{"#{x}" => "text"} end)

      fact_table_name = "fact_table_#{fact_table_id}"

      create_fact_table(fact_table_name, headers, data)

      data = Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [])

      columns =
        Ecto.Adapters.SQL.query!(
          Repo,
          "select column_name, data_type from information_schema.columns where table_name = \'#{
            fact_table_name
          }\'",
          [],
          timeout: :infinity
        )

      columns = columns.rows |> Enum.map(fn [a, b] -> %{"#{a}" => b} end)

      %{
        headers: columns,
        data: data.rows,
        total: total_no_of_rec(fact_table_name)
      }
    else
      %{error: "no data present"}
    end
  end

  def gen_comp_asset_data(%{fact_table_id: fact_table_id, asset_types: asset_types}) do
    [
      %{
        "id" => id,
        "name" => _,
        "metadata_name" => metadata_name,
        "metadata_id" => metadata_id
      }
    ] = asset_types

    {headers, data} =
      if metadata_name == "name" do
        data1 =
          from(asset in Asset,
            where: asset.asset_type_id == ^id,
            select: [asset.name]
          )
          |> Repo.all()

        headers = [%{"name" => "text"}]
        {headers, data1}
      else
        data1 =
          from(asset in Asset,
            where: asset.asset_type_id == ^id,
            cross_join: c in fragment("unnest(?)", asset.metadata),
            where: fragment("?->>'uuid'", c) in ^[metadata_id],
            select: [
              fragment("?->>'value'", c)
            ]
          )
          |> Repo.all()

        headers = [%{"#{metadata_name}" => "text"}]
        {headers, data1}
      end

    if data != [] do
      fact_table_name = "fact_table_#{fact_table_id}"

      create_fact_table(fact_table_name, headers, data)

      data = Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [])

      headers_metadata = %{"#{id}" => %{"#{metadata_id}" => 0}}

      {:ok, fact_table} = FactTables.get_by_id(fact_table_id)

      {:ok, _} =
        FactTables.update(fact_table, %{
          headers_metadata: %{"rows_len" => 1, "headers" => headers_metadata}
        })

      columns =
        Ecto.Adapters.SQL.query!(
          Repo,
          "select column_name, data_type from information_schema.columns where table_name = \'#{
            fact_table_name
          }\'",
          [],
          timeout: :infinity
        )

      columns = columns.rows |> Enum.map(fn [a, b] -> %{"#{a}" => b} end)

      %{
        headers: columns,
        data: data.rows,
        total: total_no_of_rec(fact_table_name)
      }
    else
      %{error: "no data present"}
    end
  end

  def gen_comp_sensor_data(%{fact_table_id: fact_table_id, sensor_types: sensor_types}) do
    [
      %{
        "id" => id,
        "name" => name,
        "metadata_name" => metadata_name,
        "metadata_id" => metadata_id
      }
    ] = sensor_types

    output =
      if metadata_name == "name" do
        query =
          from(sensor in Sensor,
            where: sensor.sensor_type_id == ^id,
            select: [sensor.name]
          )

        %{headers: [%{"#{name}" => "text"}], data: Repo.all(query)}
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
        query = SensorData.fetch_sensors_values_n_timeseries(query, [metadata_id])

        %{
          headers: [
            %{"#{name} #{metadata_name}" => "numeric"},
            %{"#{name} #{metadata_name}_dateTime" => "timestamp"}
          ],
          data: Repo.all(query)
        }
      end

    if output[:data] != [] do
      headers_metadata =
        if metadata_name == "name",
          do: %{"#{id}" => %{"#{metadata_id}" => 0}},
          else: %{"#{id}" => %{"#{metadata_id}" => 0, "#{metadata_id}_dateTime" => 1}}

      {:ok, fact_table} = FactTables.get_by_id(fact_table_id)

      {:ok, _} =
        FactTables.update(fact_table, %{
          headers_metadata: %{
            "rows_len" => length(output[:headers]),
            "headers" => headers_metadata
          }
        })

      fact_table_name = "fact_table_#{fact_table_id}"

      create_fact_table(fact_table_name, output[:headers], output[:data])

      data = Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [])

      columns =
        Ecto.Adapters.SQL.query!(
          Repo,
          "select column_name, data_type from information_schema.columns where table_name = \'#{
            fact_table_name
          }\'",
          [],
          timeout: :infinity
        )

      columns = columns.rows |> Enum.map(fn [a, b] -> %{"#{a}" => b} end)

      %{
        headers: columns,
        data: data.rows,
        total: total_no_of_rec(fact_table_name)
      }
    else
      %{error: "no data present"}
    end
  end

  def fetch_descendants(fact_table_id, parent_tree, root_node, entities_list, _) do
    {subtree, node_tracker} = traverse_n_gen_subtree(parent_tree, root_node, entities_list, [])

    if Enum.sort(Enum.uniq(List.flatten(node_tracker))) == Enum.sort(entities_list) do
      subtree = NaryTree.from_map(subtree)

      try do
        build_dynamic_query(fact_table_id, subtree, entities_list)
      rescue
        error in Postgrex.Error ->
          {:error, error.postgres.message}
      end
    else
      {:error, "All entities are not directly connected, please connect common parent entity."}
    end
  end

  def build_dynamic_query(fact_table_id, subtree, user_list) do
    node = NaryTree.get(subtree, subtree.root)

    # [_, id] = String.split(subtree.root, "_")
    # id = subtree.root
    [asset_id | _] = String.split(node.id, "_")

    data =
      if node.content != :empty && node.content != ["name"] do
        AssetModel.fetch_asset_metadata(asset_id, node.content)
      else
        from(asset in Asset,
          where: asset.asset_type_id == ^asset_id,
          select: map(asset, [:id, :name])
        )
        |> Repo.all()
      end

    res = fetch_data_using_dynamic_query(subtree, node, data, user_list)

    output = Map.merge(%{"#{node.id}" => data}, res)

    fact_table_representation(fact_table_id, output, subtree, user_list)
  end

  def fact_table_representation(fact_table_id, output, subtree, user_list) do
    fact_table_name = "fact_table_#{fact_table_id}"
    headers_metadata = output |> parse_table_headers_map(subtree)
    {headers, rows_len} = headers_metadata
    headers_metadata = %{"rows_len" => rows_len, "headers" => headers}

    {:ok, fact_table} = FactTables.get_by_id(fact_table_id)

    {:ok, _} =
      FactTables.update(fact_table, %{
        headers_metadata: headers_metadata
      })

    tree_elem = output[subtree.root]

    data =
      Enum.reduce(tree_elem, [], fn parent_entity, acc ->
        node = NaryTree.get(subtree, subtree.root)

        res =
          Enum.reduce(node.children, [], fn child_entity, acc1 ->
            acc1 ++
              compute_table_data(output, subtree, headers, rows_len, parent_entity, child_entity)
          end)

        acc ++ res
      end)

    if data == [] do
      %{error: "No data present for the specified user inputs"}
    else
      table_headers = gen_fact_table_headers(user_list, headers_metadata)

      create_fact_table(fact_table_name, table_headers, data)

      data =
        Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [],
          timeout: :infinity
        )

      columns =
        Ecto.Adapters.SQL.query!(
          Repo,
          "select column_name, data_type from information_schema.columns where table_name = \'#{
            fact_table_name
          }\'",
          [],
          timeout: :infinity
        )

      columns = columns.rows |> Enum.map(fn [a, b] -> %{"#{a}" => b} end)

      %{headers: columns, data: data.rows, total: total_no_of_rec(fact_table_name)}
    end
  end

  def compute_table_data(output, subtree, headers, rows_len, parent_entity, child_entity) do
    Enum.reduce(output[child_entity], [], fn entity, acc3 ->
      if entity.parent_id == parent_entity.id do
        empty_row = List.duplicate(nil, rows_len)
        child_node = NaryTree.get(subtree, child_entity)

        computed_row =
          if headers[child_node.parent]["name"] do
            List.replace_at(empty_row, headers[child_node.parent]["name"], parent_entity[:name])
          else
            empty_row
          end

        computed_row =
          if parent_entity[:metadata_name] do
            List.replace_at(
              computed_row,
              headers[child_node.parent][parent_entity.metadata_uuid],
              parent_entity.value
            )
          else
            computed_row
          end

        computed_row =
          if headers[child_entity]["name"] do
            List.replace_at(computed_row, headers[child_entity]["name"], entity[:name])
          else
            computed_row
          end

        computed_row =
          if entity[:metadata_name] do
            List.replace_at(
              computed_row,
              headers[child_entity][entity.metadata_uuid],
              entity.value
            )
          else
            computed_row
          end

        computed_row =
          if entity[:param_name] do
            computed_row =
              List.replace_at(
                computed_row,
                headers[child_entity][entity.param_uuid],
                entity.value
              )

            List.replace_at(
              computed_row,
              headers[child_entity]["#{entity.param_uuid}_dateTime"],
              entity.time
            )
          else
            computed_row
          end

        data = fetch_children(child_node, entity, subtree, output, computed_row, headers)

        if data != [], do: acc3 ++ data, else: acc3 ++ [computed_row]
      else
        acc3
      end
    end)
  end

  def compute_table_row_len(subtree) do
    Enum.reduce(subtree.nodes, 0, fn {_, node}, size ->
      if node.content != :empty do
        if node.type == "SensorType" and node.content != ["name"] do
          len = length(node.content -- ["name"]) * 2
          if Enum.member?(node.content, "name"), do: size + len + 1, else: size + len
        else
          size + length(node.content)
        end
      else
        size + 1
      end
    end)
  end

  def parse_table_headers_map(output, subtree) do
    Map.keys(output)
    |> Enum.uniq()
    |> Stream.with_index(0)
    |> Enum.reduce({%{}, 0}, fn {entity_type_id, _}, {acc, pos} ->
      {index_pos, res} =
        Stream.with_index(subtree.nodes[entity_type_id].content, pos)
        |> Enum.reduce({pos, %{}}, fn {v, table_indx}, {_, acc} ->
          if subtree.nodes[entity_type_id].type == "SensorType" and v != "name" do
            ind_pos_of_entity =
              Enum.find_index(subtree.nodes[entity_type_id].content, fn x -> x == v end)

            name_pos =
              Enum.find_index(subtree.nodes[entity_type_id].content, fn x -> x == "name" end)

            table_indx =
              if ind_pos_of_entity != 0 do
                if name_pos == ind_pos_of_entity - 1 do
                  if name_pos != 0, do: table_indx + 1, else: table_indx
                else
                  if name_pos < ind_pos_of_entity,
                    do: table_indx + ind_pos_of_entity - 1,
                    else: table_indx + ind_pos_of_entity
                end
              else
                table_indx
              end

            acc = Map.put(acc, v, table_indx)
            {table_indx + 1, Map.put(acc, "#{v}_dateTime", table_indx + 1)}
          else
            name_pos =
              Enum.find_index(subtree.nodes[entity_type_id].content, fn x -> x == "name" end)

            if subtree.nodes[entity_type_id].type == "SensorType" and v == "name" and
                 name_pos != 0,
               do: {table_indx + name_pos, Map.put(acc, v, table_indx + name_pos)},
               else: {table_indx, Map.put(acc, v, table_indx)}
          end
        end)

      acc = Map.put(acc, entity_type_id, res)
      {acc, index_pos + 1}
    end)
  end

  def gen_fact_table_headers(user_list, %{"rows_len" => rows_len, "headers" => headers}) do
    empty_headers = List.duplicate(nil, rows_len)

    user_list
    |> Enum.reduce(empty_headers, fn entity, acc ->
      pos = headers["#{entity["id"]}_#{entity["name"]}"]["#{entity["metadata_id"]}"]

      if entity["metadata_name"] == entity["metadata_id"] do
        List.replace_at(
          acc,
          pos,
          %{"#{entity["name"]} #{entity["metadata_name"]}" => "text"}
        )
      else
        if entity["type"] == "AssetType" do
          [%{name: [metadata_name]}] =
            AssetTypeModel.fetch_uniq_metadata_name_by_metadata_uuid(entity["id"], [
              entity["metadata_id"]
            ])

          # ["#{entity["name"]} #{metadata_name}"]
          List.replace_at(
            acc,
            pos,
            %{"#{entity["name"]} #{metadata_name}" => "text"}
          )
        else
          [%{name: [param_name]}] =
            SensorTypeModel.fetch_uniq_param_name_by_param_uuid(entity["id"], [
              entity["metadata_id"]
            ])

          acc =
            List.replace_at(
              acc,
              pos,
              %{"#{entity["name"]} #{param_name}" => "numeric"}
            )

          pos = headers["#{entity["id"]}_#{entity["name"]}"]["#{entity["metadata_id"]}_dateTime"]

          pos_dateTime = headers["#{entity["id"]}_#{entity["name"]}"]["entity_dateTime"]

          if pos_dateTime do
            List.replace_at(
              acc,
              pos_dateTime,
              %{"entity_dateTime" => "timestamp"}
            )
          else
            List.replace_at(
              acc,
              pos,
              %{"#{entity["name"]} #{param_name}_dateTime" => "timestamp"}
            )
          end
        end
      end
    end)
  end

  def create_fact_table(fact_table_name, table_headers, data) do
    Ecto.Adapters.SQL.query!(Repo, "drop table if exists #{fact_table_name};", [],
      timeout: :infinity
    )

    {qry_text, headers, col_types} = gen_fact_table_column(table_headers)

    {qry_text, _} = String.split_at(qry_text, -1)

    {headers, _} = String.split_at(headers, -1)
    gen_table(fact_table_name, qry_text)

    data
    |> Stream.chunk_every(500)
    |> Task.async_stream(
      fn data ->
        text_form = convert_table_data_to_text(data, col_types)

        qry = """
          INSERT INTO #{fact_table_name}
          (#{headers})
          VALUES
          #{text_form};
        """

        Ecto.Adapters.SQL.query!(Repo, qry, [])
      end,
      max_concurrency: 4,
      timeout: :infinity
    )
    |> Stream.run()
  end

  def fetch_children(parent_node, parent_entity, subtree, output, computed_row, headers) do
    Enum.reduce(parent_node.children, [], fn child_entity, acc1 ->
      res1 =
        Enum.reduce(output[child_entity], [], fn entity, acc3 ->
          if entity.parent_id == parent_entity.id do
            computed_row =
              if headers[child_entity]["name"] do
                List.replace_at(computed_row, headers[child_entity]["name"], entity[:name])
              else
                computed_row
              end

            computed_row =
              if entity[:metadata_name] do
                List.replace_at(
                  computed_row,
                  headers[child_entity][entity.metadata_uuid],
                  entity.value
                )
              else
                computed_row
              end

            computed_row =
              if entity[:param_name] do
                computed_row =
                  List.replace_at(
                    computed_row,
                    headers[child_entity][entity.param_uuid],
                    entity.value
                  )

                List.replace_at(
                  computed_row,
                  headers[child_entity]["#{entity.param_uuid}_dateTime"],
                  entity.time
                )
              else
                computed_row
              end

            child_node = NaryTree.get(subtree, child_entity)
            data = fetch_children(child_node, entity, subtree, output, computed_row, headers)
            if data != [], do: acc3 ++ data, else: acc3 ++ [computed_row]
          else
            acc3
          end
        end)

      acc1 ++ res1
    end)
  end

  def broadcast_to_channel(fact_table_id) do
    output = fetch_paginated_fact_table(fact_table_id, 1, 20)

    AcqdatApiWeb.Endpoint.broadcast("project_fact_table:#{fact_table_id}", "out_put_res", %{
      data: output
    })
  end

  def fetch_paginated_fact_table(fact_table_id, page_number, page_size) do
    fact_table_name = "fact_table_#{fact_table_id}"
    offset = page_size * (page_number - 1)

    {:ok, fact_table} = FactTables.get_by_id(fact_table_id)

    data =
      Ecto.Adapters.SQL.query!(
        Repo,
        "select * from #{fact_table_name} OFFSET #{offset} LIMIT 20",
        [],
        timeout: :infinity
      )

    headers =
      if fact_table.headers_metadata do
        gen_fact_table_headers(fact_table.columns_metadata, fact_table.headers_metadata)
      else
        data.columns
      end

    %{headers: headers, data: data.rows, total: total_no_of_rec(fact_table_name)}
  end

  def fetch_data_using_dynamic_query(subtree, tree_node, parent_data, user_list) do
    Enum.reduce(tree_node.children, %{}, fn id, acc ->
      node = NaryTree.get(subtree, id)
      [id | _] = String.split(id, "_")
      entities = Enum.map(parent_data, fn entity -> entity[:id] end) |> Enum.uniq()

      query =
        if node.content != [] && node.content != :empty && node.content != ["name"] do
          content = node.content -- ["name"]

          if node.type == "AssetType" do
            from(asset in Asset,
              where: asset.asset_type_id == ^id and asset.parent_id in ^entities,
              cross_join: c in fragment("unnest(?)", asset.metadata),
              where: fragment("?->>'uuid'", c) in ^content,
              select: %{
                id: asset.id,
                name: asset.name,
                parent_id: asset.parent_id,
                value: fragment("?->>'value'", c),
                metadata_name: fragment("?->>'name'", c),
                metadata_uuid: fragment("?->>'uuid'", c)
              }
            )
          else
            subquery =
              from(sensor in Sensor,
                where:
                  sensor.sensor_type_id == ^id and sensor.parent_id in ^entities and
                    sensor.parent_type == "Asset",
                select: sensor.id
              )

            sensor_ids = Repo.all(subquery)

            if sensor_ids != [] do
              sensor_entity =
                Enum.filter(user_list, fn x ->
                  "#{x["id"]}" == id && x["type"] == node.type
                end)

              [
                %{
                  "metadata_name" => _,
                  "date_to" => date_to,
                  "date_from" => date_from
                }
                | _
              ] = sensor_entity

              parameter_ids = Enum.map(sensor_entity, fn entity -> entity["metadata_id"] end)

              date_from = from_unix(date_from)
              date_to = from_unix(date_to)

              query = SensorData.filter_by_date_query_wrt_parent(sensor_ids, date_from, date_to)
              SensorData.fetch_sensors_data_with_parent_id(query, parameter_ids)
            else
              subquery
            end
          end
        else
          if node.type == "AssetType" do
            from(asset in Asset,
              where: asset.asset_type_id == ^id and asset.parent_id in ^entities,
              select: map(asset, [:id, :name, :parent_id])
            )
          else
            from(sensor in Sensor,
              where:
                sensor.sensor_type_id == ^id and sensor.parent_id in ^entities and
                  sensor.parent_type == "Asset",
              select: map(sensor, [:id, :name, :parent_id])
            )
          end
        end

      entity_data = Repo.all(query, timeout: :infinity)

      entity_data =
        if entity_data == [] do
          parent_data = Enum.map(parent_data, fn entity -> entity[:id] end) |> Enum.uniq()
          assets = AssetModel.get_all_by_ids(parent_data)

          Enum.reduce(assets, [], fn asset, acc ->
            data = AssetModel.fetch_child_descendants(asset)

            res =
              if node.type == "AssetType" do
                Enum.reduce(data, [], fn x, acc1 ->
                  if "#{x.asset_type_id}" == id,
                    do: acc1 ++ [%{parent_id: asset.id, name: x.name, id: x.id}],
                    else: acc1
                end)
              else
                list = Enum.map(data, fn x -> x.id end)

                entity_ids =
                  from(sensor in Sensor,
                    where:
                      sensor.sensor_type_id == ^id and sensor.parent_id in ^list and
                        sensor.parent_type == "Asset",
                    select: sensor.id
                  )
                  |> Repo.all()

                sensor_entity =
                  Enum.filter(user_list, fn x ->
                    "#{x["id"]}" == id && x["type"] == node.type
                  end)

                [
                  %{
                    "metadata_name" => _,
                    "date_to" => date_to,
                    "date_from" => date_from
                  }
                  | _
                ] = sensor_entity

                parameter_ids = Enum.map(sensor_entity, fn entity -> entity["metadata_id"] end)

                date_from = from_unix(date_from)
                date_to = from_unix(date_to)

                query = SensorData.fetch_sensor_data_btw_time_intv(entity_ids, date_from, date_to)

                output = SensorData.fetch_sensors_data(query, parameter_ids) |> Repo.all()
                Enum.map(output, fn x -> Map.merge(%{parent_id: asset.id}, x) end)
              end

            acc ++ res
          end)
        else
          entity_data
        end

      res1 = fetch_data_using_dynamic_query(subtree, node, entity_data, user_list)
      res2 = Map.put_new(acc, node.id, entity_data)
      Map.merge(res2, res1)
    end)
  end

  defp traverse_n_gen_subtree(tree, tree_node, entities_list, node_tracker) do
    {data, metadata} =
      Enum.reduce(entities_list, {[], []}, fn x, {acc1, acc2} ->
        if "#{x["id"]}_#{x["name"]}" == tree_node.id && x["type"] == tree_node.type do
          {acc1 ++ [x], acc2 ++ [x["metadata_id"]]}
        else
          {acc1, acc2}
        end
      end)

    node_tracker =
      if data && metadata != [] do
        node_tracker ++ data
      else
        node_tracker
      end

    subtree_map =
      if data != [],
        do: %{
          id: tree_node.id,
          name: tree_node.name,
          type: tree_node.type,
          content: metadata,
          children: []
        },
        else: []

    case tree_node.children do
      [] ->
        {subtree_map, node_tracker}

      _ ->
        Enum.reduce(tree_node.children, {subtree_map, node_tracker}, fn child_id, {acc1, acc2} ->
          node = NaryTree.get(tree, child_id)
          res = traverse_n_gen_subtree(tree, node, entities_list, node_tracker)
          {data, data2} = res

          if res != nil && acc1 != %{} && acc1 != [] do
            items = acc1[:children] ++ [data]
            acc1 = acc1 |> Map.put(:children, List.flatten(items))
            acc2 = acc2 ++ data2
            {acc1, acc2}
          else
            acc2 = acc2 ++ data2
            acc1 = acc1 ++ data
            {acc1, acc2}
          end
        end)
    end
  end

  defp gen_fact_table_column(table_headers) do
    Enum.reduce(table_headers, {"", "", []}, fn entity, {acc, keys, types} ->
      [key] = Map.keys(entity)
      [value] = Map.values(entity)
      acc = acc <> "\"#{key}\" #{value},"
      keys = keys <> "\"#{key}\","
      types = types ++ [value]
      {acc, keys, types}
    end)
  end

  defp gen_table(fact_table_name, qry_text) do
    qry = """
      CREATE TABLE #{fact_table_name}
      (#{qry_text})
    """

    Ecto.Adapters.SQL.query!(Repo, qry, [])
  end

  defp convert_table_data_to_text(data, col_types) do
    text_form =
      Enum.reduce(data, "", fn ele, acc ->
        res =
          Stream.with_index(ele, 0)
          |> Enum.reduce("", fn {val, ind}, acc ->
            if Enum.at(col_types, ind) != "text" and val == nil do
              acc <> "null,"
            else
              acc <> "\'#{val}\',"
            end
          end)

        {res, _} = String.split_at(res, -1)
        acc <> "(" <> res <> "),"
      end)

    {text_form, _} = String.split_at(text_form, -1)
    text_form
  end

  defp delete_temp_fact_table_view(%{id: id}) do
    fact_table_name = "fact_table_#{id}"

    qry = """
      drop table if exists #{fact_table_name}
    """

    res = Ecto.Adapters.SQL.query!(Repo, qry, [], timeout: :infinity)
    {:ok, res.rows}
  end

  def total_no_of_rec(fact_table_name) do
    res =
      Ecto.Adapters.SQL.query!(Repo, "select count(*) from #{fact_table_name}", [],
        timeout: :infinity
      )

    res.rows |> List.first() |> List.first()
  end

  defp from_unix(datetime) do
    {datetime, _} = Integer.parse(datetime)
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end

  defp run_under_transaction(multi, _) do
    multi
    |> Repo.transaction(timeout: :infinity)
    |> case do
      {:ok, result} ->
        {:ok, result[:del_rec_frm_fact_tab]}

      {:error, _, failed_value, _} ->
        {:error, failed_value}
    end
  end
end
