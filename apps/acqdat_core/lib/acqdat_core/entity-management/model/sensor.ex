defmodule AcqdatCore.Model.EntityManagement.Sensor do
  alias AcqdatCore.Schema.EntityManagement.{Sensor, SensorsData, SensorType}
  alias AcqdatCore.Domain.EntityManagement.SensorData, as: SensorDataDomain
  alias AcqdatCore.Repo
  alias AcqdatCore.ElasticSearch
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias Elixlsx.{Workbook, Sheet}
  alias AcqdatCore.Model.IotManager.Gateway
  import Ecto.Query
  alias AcqdatApi.DataStructure.Queues.Rabbitmq.Amqp

  def create(params) do
    changeset = Sensor.changeset(%Sensor{}, params)

    case Repo.insert(changeset) do
      {:ok, sensor} ->
        Task.start_link(fn ->
          ElasticSearch.insert_sensor("sensors", sensor)
        end)

        publish_to_rabbitmq(sensor)

        {:ok, sensor}

      {:error, message} ->
        {:error, message}
    end
  end

  def return_count(%{"type" => "Sensor", "project_id" => project_id}) do
    query =
      from(p in Sensor,
        where: p.project_id == ^project_id,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def return_count(%{"type" => "Sensor"}) do
    query =
      from(p in Sensor,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def update(sensor, params) do
    changeset = Sensor.update_changeset(sensor, params)

    case Repo.update(changeset) do
      {:ok, sensor} ->
        Task.start_link(fn ->
          ElasticSearch.insert_sensor("sensors", sensor)
        end)

        {:ok, sensor}

      {:error, message} ->
        {:error, message}
    end
  end

  def get_for_view(sensor_ids) do
    query =
      from(sensor in Sensor,
        where: sensor.id in ^sensor_ids,
        preload: [:sensor_type],
        order_by: [desc: :inserted_at]
      )

    Repo.all(query)
  end

  def get(identifier, preloads \\ [])

  def get(id, preloads) when is_integer(id) do
    case Repo.get(Sensor, id) do
      nil ->
        {:error, "not found"}

      sensor ->
        sensor = Repo.preload(sensor, [:sensor_type] ++ preloads)
        {:ok, sensor}
    end
  end

  def get(query, preloads) when is_map(query) do
    case Repo.get_by(Sensor, query) do
      nil ->
        {:error, "not found"}

      sensor ->
        sensor = Repo.preload(sensor, [:sensor_type] ++ preloads)
        {:ok, sensor}
    end
  end

  def return_sensor_gatewap_mapping(org_id, project_id) do
    query =
      from(sensor in Sensor,
        where:
          sensor.org_id == ^org_id and sensor.project_id == ^project_id and
            is_nil(sensor.gateway_id) == false
      )

    Repo.all(query)
  end

  def remove_sensor(sensor_ids) do
    query =
      from(sensor in Sensor,
        where: sensor.id in ^sensor_ids
      )

    Repo.update_all(query, set: [gateway_id: nil])
  end

  def add_sensor(sensor_ids, gateway) do
    query1 =
      from(sensor in Sensor,
        where: sensor.id in ^sensor_ids,
        select: sensor.gateway_id
      )

    gateway_ids = Repo.all(query1)

    query2 =
      from(sensor in Sensor,
        where: sensor.id in ^sensor_ids
      )

    case List.first(gateway_ids) do
      nil ->
        :ok

      _ ->
        Gateway.modify_mapped_parameters(gateway_ids, sensor_ids)
    end

    Repo.update_all(query2, set: [gateway_id: gateway.id])
  end

  def get_all_by_sensor_type(entity_ids) do
    Sensor
    |> where([sensor], sensor.sensor_type_id in ^entity_ids)
    |> order_by(:id)
    |> Repo.all()
  end

  # def get_all_by_sensor_type(sensor_type_id) do
  #   from(sensor in Sensor,
  #     where: sensor.sensor_type_id == ^sensor_type_id,
  #     select: map(sensor, [:id, :name])
  #   )
  #   |> Repo.all()
  # end

  def get_all_by_parent_gateway(gateway_ids) do
    Sensor
    |> where([sensor], sensor.gateway_id in ^gateway_ids)
    |> preload([:sensor_type])
    |> Repo.all()
  end

  def get_all_by_parent_project(project_id) do
    Sensor
    |> where([sensor], sensor.project_id == ^project_id)
    |> where([sensor], sensor.parent_type == "Project")
    |> preload([:sensor_type])
    |> Repo.all()
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Sensor |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_sensor_data =
      Sensor |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    sensor_data_with_preloads = paginated_sensor_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(sensor_data_with_preloads, paginated_sensor_data)
  end

  def get_all_by_project_n_org(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id
      }) do
    paginated_sensor_data =
      Sensor
      |> where([sensor], sensor.project_id == ^project_id)
      |> where([sensor], sensor.org_id == ^org_id)
      |> order_by(:id)
      |> Repo.paginate(page: page_number, page_size: page_size)

    sensor_data_with_preloads = paginated_sensor_data.entries |> Repo.preload([:sensor_type])

    ModelHelper.paginated_response(sensor_data_with_preloads, paginated_sensor_data)
  end

  def get_all_by_device(device_id) do
    query =
      from(sensor in Sensor,
        where: sensor.device_id == ^device_id,
        select: sensor
      )

    Repo.all(query)
  end

  def get_all_by_criteria(id, preloads) when is_integer(id) do
    query =
      from(sensor in Sensor,
        where: sensor.device_id == ^id,
        select: sensor
      )

    Repo.all(query) |> Repo.preload(preloads)
  end

  def child_sensors_query(root) when not is_list(root) do
    from(sensor in Sensor,
      preload: [:sensor_type, :gateway],
      where: sensor.parent_id == ^root.id and sensor.parent_type == "Asset"
    )
  end

  def child_sensors_query(asset_ids) when is_list(asset_ids) do
    from(sensor in Sensor,
      preload: [:sensor_type],
      where: sensor.parent_id in ^asset_ids and sensor.parent_type == "Asset"
    )
  end

  def child_sensors(root, sensor_type_ids) when not is_list(root) do
    from(sensor in Sensor,
      preload: [:sensor_type],
      where:
        sensor.parent_id == ^root.id and sensor.parent_type == "Asset" and
          sensor.sensor_type_id in ^sensor_type_ids
    )
    |> Repo.all()
  end

  def child_sensors(root) do
    child_sensors_query(root)
    |> Repo.all()
  end

  def get_all() do
    Repo.all(Sensor)
  end

  def delete_data(:sensors_data, %{"org_id" => org_id, "project_id" => project_id} = params) do
    query =
      SensorsData
      |> where([data], data.org_id == ^org_id and data.project_id == ^project_id)
      |> where(^filter_where(params))

    Repo.delete_all(query)
  end

  def get_all_sensors_data(%{
        page_size: page_size,
        page_number: page_number,
        sensor_id: sensor_id,
        org_id: org_id,
        project_id: project_id
      }) do
    query1 =
      from(data in SensorsData,
        where:
          data.sensor_id == ^sensor_id and data.org_id == ^org_id and
            data.project_id == ^project_id
      )

    query =
      from(data in query1,
        cross_join: c in fragment("unnest(?)", data.parameters),
        order_by: [asc: data.inserted_timestamp],
        select: [
          fragment("?->>'name'", c),
          fragment("?->>'uuid'", c),
          data.inserted_timestamp,
          fragment("CAST(ROUND(CAST (?->>'value' AS NUMERIC), 2) AS FLOAT)", c),
          data.sensor_id
        ]
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"sensor_id", sensor_id}, dynamic_query ->
        dynamic(
          [data],
          ^dynamic_query and data.sensor_id == ^sensor_id
        )

      {"gateway_id", gateway_id}, dynamic_query ->
        dynamic(
          [data],
          ^dynamic_query and data.gateway_id == ^gateway_id
        )

      {"start_time", start_date}, dynamic_query ->
        end_date = params["end_time"]
        {:ok, start_time, _notrequired} = DateTime.from_iso8601(start_date)
        {:ok, end_time, _notrequired} = DateTime.from_iso8601(end_date)

        dynamic(
          [data],
          ^dynamic_query and
            fragment("? BETWEEN ? AND ?", data.inserted_timestamp, ^start_time, ^end_time)
        )

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end

  def delete(sensor_id) do
    sensor = Repo.get(Sensor, sensor_id)

    if has_iot_data?(sensor.id, sensor.project_id) do
      {:error, "It contains time-series data. Please delete sensors data before deleting sensor."}
    else
      case Repo.delete(sensor) do
        {:ok, sensor} ->
          Task.start_link(fn ->
            ElasticSearch.delete("sensors", sensor.id)
          end)

          {:ok, sensor |> Repo.preload(:sensor_type)}

        {:error, message} ->
          {:error, message}
      end
    end
  end

  def fetch_sensor_by_parameters(%{
        "entities" => entities,
        "date_from" => date_from,
        "date_to" => date_to,
        "email_to" => email_to
      }) do
    [input_params, param_uuids, sensor_ids] =
      Enum.reduce(entities, [[], [], []], fn param, [acc1, acc2, acc3] ->
        [
          ["#{param["sensor_id"]}_#{param["param_uuid"]}" | acc1],
          [param["param_uuid"] | acc2],
          [param["sensor_id"] | acc3]
        ]
      end)

    date_from = from_unix(date_from)
    date_to = from_unix(date_to)

    input_params = Enum.uniq(input_params)
    param_uuids = Enum.uniq(param_uuids)
    sensor_ids = Enum.uniq(sensor_ids)

    sensors =
      from(
        sensor in Sensor,
        join: sensor_type in SensorType,
        on: sensor.sensor_type_id == sensor_type.id,
        cross_join: c in fragment("unnest(?)", sensor_type.parameters),
        where: sensor.id in ^sensor_ids and fragment("?->>'uuid'", c) in ^param_uuids,
        select: %{
          sensor_id: sensor.id,
          sensor_name: sensor.name,
          gateway_id: sensor.gateway_id,
          param_name: fragment("?->>'name'", c),
          param_uuid: fragment("?->>'uuid'", c)
        }
      )
      |> Repo.all()

    data_grouped_by_gateway = Enum.group_by(sensors, fn sensor -> sensor.gateway_id end)

    gateway_ids = Map.keys(data_grouped_by_gateway)

    if Enum.filter(gateway_ids, &(!is_nil(&1))) == [] do
      {:error, "no gateways present for the specified sensors entities"}
    else
      Task.async(fn ->
        compute_gateway_data(
          data_grouped_by_gateway,
          gateway_ids,
          sensor_ids,
          input_params,
          date_from,
          date_to
        )
        |> AcqdatCore.Mailer.DashboardReportEmail.email(email_to)
        |> AcqdatCore.Mailer.deliver_now()
      end)

      {:ok, "You'll receive report on this #{email_to} email"}
    end
  end

  defp compute_gateway_data(
         data_grouped_by_gateway,
         gateway_ids,
         sensor_ids,
         input_params,
         date_from,
         date_to
       ) do
    workbook = {:ok, %Workbook{}}

    gateway_data = Gateway.get_names_by_ids(gateway_ids)

    Enum.reduce(data_grouped_by_gateway, workbook, fn {gateway_id, value}, acc ->
      {:ok, workbook} = acc

      if gateway_id != nil do
        [header_uuids, header_names] =
          Enum.reduce(value, [[], []], fn entity, [header_uuids, header_names] ->
            if Enum.member?(input_params, "#{entity.sensor_id}_#{entity.param_uuid}") do
              [
                ["#{entity.sensor_id}_#{entity.param_uuid}" | header_uuids],
                ["#{entity.sensor_name} #{entity.param_name}" | header_names]
              ]
            else
              [header_uuids, header_names]
            end
          end)

        header_uuids = Enum.uniq(header_uuids)
        header_names = Enum.uniq(header_names)

        [%{name: gateway_name}] = Enum.filter(gateway_data, fn data -> data.id == gateway_id end)

        trans =
          Repo.transaction(
            fn ->
              SensorDataDomain.filter_by_date_query_wrt_format(sensor_ids, date_from, date_to)
              |> Repo.stream(max_rows: 1000)
              |> Stream.map(fn grouped_data ->
                [timestamp, sensor_data] = grouped_data
                rows_len = length(header_uuids)

                empty_row = List.duplicate(nil, rows_len)

                res =
                  Enum.reduce(sensor_data, [], fn {sensor_id, params}, _acc ->
                    Enum.reduce(params, empty_row, fn param, acc1 ->
                      indx_pos =
                        Enum.find_index(header_uuids, fn x ->
                          x == "#{sensor_id}_#{param["uuid"]}"
                        end)

                      if indx_pos != nil,
                        do: List.replace_at(acc1, indx_pos, param["value"]),
                        else: acc1
                    end)
                  end)

                res =
                  if res != empty_row do
                    ["#{timestamp}" | res]
                  end

                res
              end)
              |> Enum.filter(&(!is_nil(&1)))
              |> Enum.to_list()
              |> gen_xls_sheet(header_names, gateway_name, workbook)
            end,
            timeout: :infinity
          )

        trans
      else
        acc
      end
    end)
    |> write_to_xls()
  end

  def gen_xls_sheet(data, headers, gateway_name, workbook) do
    headers = ["#{gateway_name} timestamp" | headers]
    sheet_name = "#{gateway_name} data"

    sheet_name = String.slice(sheet_name, 0..(32 - String.length(sheet_name)))

    sheet = %Sheet{name: sheet_name, rows: [headers] ++ data}

    Workbook.append_sheet(workbook, sheet)
  end

  def write_to_xls({:ok, workbook}) do
    path =
      Application.app_dir(
        :acqdat_api,
        "priv/static/reports/gateways/report_#{String.slice(UUID.uuid1(:hex), 0..6)}.xlsx"
      )

    workbook |> Elixlsx.write_to(path)

    path
  end

  defp has_iot_data?(sensor_id, project_id) do
    query =
      from(
        data in SensorsData,
        where: data.sensor_id == ^sensor_id and data.project_id == ^project_id
      )

    Repo.exists?(query)
  end

  defp from_unix(datetime) do
    {datetime, _} = Integer.parse(datetime)
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end

  defp publish_to_rabbitmq(sensor) do
    Task.start_link(fn ->
      sensor = sensor |> Repo.preload(:sensor_type)

      params = %{
        project_id: sensor.project_id,
        entity_type: "SensorType",
        entity_name: sensor.sensor_type.name,
        entity_id: sensor.sensor_type.id,
        entity_source_name: "name",
        entity_source_val: sensor.name,
        entity_source_id: sensor.id,
        event_generator: "entity_manager",
        event_id: Timex.now()
      }

      Amqp.publish_thr_exc("entity_exch", "entity.SensorType.#{sensor.sensor_type.id}", params)
    end)
  end
end
