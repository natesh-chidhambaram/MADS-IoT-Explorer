defmodule AcqdatApi.IotManager.Data do
  alias AcqdatCore.Schema.EntityManagement.GatewayData
  alias AcqdatCore.Repo
  import Ecto.Query

  def get_all_gateway_data(%{
        page_size: page_size,
        page_number: page_number,
        gateway_id: gateway_id,
        org_id: org_id,
        project_id: project_id
      }) do
    query1 =
      from(data in GatewayData,
        where:
          data.gateway_id == ^gateway_id and data.org_id == ^org_id and
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
          data.gateway_id
        ]
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def delete_data(:gateway_data, %{org_id: org_id, project_id: project_id} = params) do
    query =
      GatewayData
      |> where([data], data.org_id == ^org_id and data.project_id == ^project_id)
      |> where(^filter_where(params))

    Repo.delete_all(query)
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
end
