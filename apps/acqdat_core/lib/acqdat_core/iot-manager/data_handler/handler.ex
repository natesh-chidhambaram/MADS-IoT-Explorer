defmodule AcqdatCore.IotManager.DataHandler do
  require Logger
  alias AcqdatCore.Model.IotManager.GatewayDataDump, as: GDDModel
  alias AcqdatCore.Schema.IoTManager.GatewayError
  alias AcqdatCore.Repo
  alias AcqdatCore.IotManager.DataParser

  @doc """
  Logs Data for the given event.

  The function first logs the data in `gateway_data_dump` table and then
  sends the response for next step of parsing.
  See `AcqdatCore.IotManager.DataParser` for the parsing logic.
  """
  def insert_data(%{mode: "mqtt"} = params) do
    %{payload: payload, meta: meta} = params
    log_data_if_valid(Jason.decode(payload), meta)
  end

  def insert_data(%{mode: "http"} = params) do
    verify_data_dump(GDDModel.create(params), params)
  end

  defp log_data_if_valid({:ok, data}, meta) do
    params = Map.put(meta, :data, data)
    verify_data_dump(GDDModel.create(params), params)
  end

  defp log_data_if_valid({:error, data}, meta) do
    data = Map.from_struct(data)
    error = Map.put(%{}, :error, "JSON Parser Error")
    params = %{data: data, error: error, gateway_uuid: meta.gateway_uuid}
    changeset = GatewayError.changeset(%GatewayError{}, params)
    {:ok, _result} = Repo.insert(changeset)
    {:error, Logger.error("JSON Parse error #{inspect(meta.gateway_uuid)} #{inspect(data.data)}")}
  end

  defp verify_data_dump({:ok, params}, _params) do
    response = DataParser.start_parsing(params)
    {:ok, response}
  end

  defp verify_data_dump({:error, error}, params) do
    result = error |> parse_error() |> log_data(params)
    {:error, result}
  end

  defp parse_error(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp parse_error(error) do
    error
  end

  defp log_data(error, params) do
    params = %{data: params.data, error: error, gateway_uuid: params.gateway_uuid}
    changeset = GatewayError.changeset(%GatewayError{}, params)
    {:ok, data} = Repo.insert(changeset)
    data
  end
end
