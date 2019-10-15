defmodule AcqdatCore.DataTrace.CronTask do
  use Task
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.SensorData

  def start_link(_args) do
    Task.start_link(&cron/0)
  end

  def cron() do
    receive do
    after
      300_000 ->
        send_data()
        cron()
        # code
    end
  end

  def send_data() do
    start_time = Timex.shift(DateTime.utc_now(), minutes: -5)
    end_time = DateTime.utc_now()

    start_time
    |> SensorData.get_by_time_range(end_time)
    |> extract_data()
    |> case do
      nil ->
        :ok

      data ->
        data_trace(data)
    end
  end

  defp data_trace(data) do
    body = Jason.encode!(data)
    headers = [{"Accept", "application/json"}]
    url = "https://innovfest19-bl.herokuapp.com/post"
    HTTPoison.post(url, body, headers)
  end

  # TODO: needs to be refactored once proper provDat is up.
  defp extract_data(query) do
    case Repo.all(query) do
      nil ->
        nil

      data ->
        result = List.first(data)

        %{
          "Device_ID" => result.sensor.device.id,
          "Timestamp" => result.inserted_timestamp,
          "Sensor" => %{
            "#{result.sensor.name}" => result.datapoint
          }
        }
    end
  end
end
