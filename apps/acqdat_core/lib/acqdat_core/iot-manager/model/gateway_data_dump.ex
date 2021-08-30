defmodule AcqdatCore.Model.IotManager.GatewayDataDump do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.IotManager.GatewayDataDump
  alias AcqdatCore.Schema.IoTManager.SensorDataError
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Schema.IoTManager.GatewayError

  @spec create(map) :: {:ok, GatewayDataDump.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    parse_params_and_insert(params)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    GatewayDataDump |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_error(
        %{page_size: page_size, page_number: page_number, gateway_uuid: gateway_uuid},
        preloads
      ) do
    query =
      from(error in GatewayError,
        where: error.gateway_uuid == ^gateway_uuid,
        order_by: [desc: error.inserted_at]
      )

    paginated_data_dump = query |> Repo.paginate(page: page_number, page_size: page_size)
    data_dump_with_preloads = paginated_data_dump.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(data_dump_with_preloads, paginated_data_dump)
  end

  def get_sensor_error(
        %{page_size: page_size, page_number: page_number, sensor_id: sensor_id},
        preloads
      ) do
    query =
      from(error in SensorDataError,
        where: error.sensor_id == ^sensor_id,
        order_by: [desc: error.inserted_at]
      )

    paginated_data_dump = query |> Repo.paginate(page: page_number, page_size: page_size)
    data_dump_with_preloads = paginated_data_dump.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(data_dump_with_preloads, paginated_data_dump)
  end

  def get_all(
        %{
          page_size: page_size,
          page_number: page_number,
          org_uuid: org_uuid,
          project_uuid: project_uuid,
          gateway_uuid: gateway_uuid
        },
        preloads
      ) do
    query =
      from(data_dump in GatewayDataDump,
        where:
          data_dump.project_uuid == ^project_uuid and
            data_dump.org_uuid == ^org_uuid and data_dump.gateway_uuid == ^gateway_uuid,
        order_by: [desc: data_dump.inserted_timestamp]
      )

    paginated_data_dump = query |> Repo.paginate(page: page_number, page_size: page_size)

    data_dump_with_preloads = paginated_data_dump.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(data_dump_with_preloads, paginated_data_dump)
  end

  def get_all_error(%{
        page_size: page_size,
        page_number: page_number,
        org_uuid: org_uuid,
        project_uuid: project_uuid,
        gateway_uuid: gateway_uuid
      }) do
    query =
      from(data_dump in GatewayError,
        where: data_dump.gateway_uuid == ^gateway_uuid
      )

    paginated_data_dump = query |> Repo.paginate(page: page_number, page_size: page_size)

    data_dump_with_preloads = paginated_data_dump.entries

    ModelHelper.paginated_response(data_dump_with_preloads, paginated_data_dump)
  end

  @doc """
  Deletes all the gateway related errors a week before the provided timestamp.
  """
  def delete_errors(timestamp) do
    previous_week_threshold = Timex.shift(timestamp, days: -7)

    query =
      from(error in GatewayError,
        where: error.inserted_at < ^previous_week_threshold
      )

    Repo.delete_all(query)
  end

  def delete_data_dumps(
        :data_dump,
        %{"org_uuid" => org_uuid, "project_uuid" => project_uuid, "gateway_uuid" => gateway_uuid} =
          params
      ) do
    query =
      GatewayDataDump
      |> where(
        [data],
        data.project_uuid == ^project_uuid and data.org_uuid == ^org_uuid and
          data.gateway_uuid == ^gateway_uuid
      )
      |> where(^filter_where(params))

    Repo.delete_all(query)
  end

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {"start_time", start_date}, dynamic_query ->
        end_date = String.to_integer(params["end_time"])
        start_date = String.to_integer(start_date)

        {:ok, start_time} = DateTime.from_unix(start_date)
        {:ok, end_time} = DateTime.from_unix(end_date)

        dynamic(
          [data],
          ^dynamic_query and
            fragment("? BETWEEN ? AND ?", data.inserted_timestamp, ^start_time, ^end_time)
        )

      {_, _}, dynamic_query ->
        dynamic_query
    end)
  end

  #################### private functions ##############################

  defp parse_params_and_insert(params) do
    has_gateway_with_uuid(Gateway.get(%{uuid: params.gateway_uuid}), params)
  end

  defp has_gateway_with_uuid({:ok, gateway}, params) do
    inserted_timestamp = set_timestamp(gateway.timestamp_mapping, params.data)

    case inserted_timestamp do
      {:error, message} ->
        {:error, message}

      {:ok, inserted_timestamp} ->
        params = Map.put(params, :inserted_timestamp, inserted_timestamp)
        changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
        Repo.insert(changeset)
    end
  end

  defp has_gateway_with_uuid({:error, message}, _params) do
    {:error, message}
  end

  defp set_timestamp(nil, _data) do
    {:ok, DateTime.utc_now() |> DateTime.to_unix()}
  end

  defp set_timestamp(key, data) do
    cond do
      check_utc_validity(Timex.parse(data[key], "{RFC3339z}")) ->
        {:ok, utc_datetime} = Timex.parse(data[key], "{RFC3339z}")
        {:ok, utc_datetime |> DateTime.to_unix()}

      check_unix_validity(cast(data[key])) ->
        {:ok, data[key]}

      true ->
        {:error, %{message: "timestamp not supported"}}
    end
  end

  defp check_utc_validity({:ok, _utc_datetime}) do
    true
  end

  defp check_utc_validity({:error, _message}) do
    false
  end

  defp check_unix_validity({:ok, _unix_timestamp}) do
    true
  end

  defp check_unix_validity({:error, _message}) do
    false
  end

  defp cast(timestamp) when is_integer(timestamp) do
    check_validity(DateTime.from_unix(timestamp))
  end

  defp cast(timestamp) when is_binary(timestamp) do
    timestamp = String.to_integer(timestamp)
    check_validity(DateTime.from_unix(timestamp))
  end

  defp cast(_timestamp) do
    {:error, %{message: "timestamp not supported"}}
  end

  defp check_validity({:ok, timestamp}) do
    {:ok, timestamp}
  end

  defp check_validity({:error, _message}) do
    {:error, %{message: "timestamp not supported"}}
  end
end
