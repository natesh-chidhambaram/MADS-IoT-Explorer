defmodule AcqdatCore.Helper.Redis do
  @moduledoc """
  Helper module for Recent Dashboard store in Redis.
  """

  @name :redix_dasbhoard
  @redis_port Application.get_env(:acqdat_api, :redis_port)
  @time_to_live 60

  def child() do
    {Redix, {@redis_port, name: @name}}
  end

  def get_gateway_activity(gateway_id) do
    case Redix.command(@name, ["GET", "gatewaydata:#{gateway_id}"]) do
      {:ok, nil} -> {:ok, []}
      {:ok, data} -> {:ok, data |> to_charlist}
      {:error, _} -> {:error, "Redis instance not running"}
    end
  end

  def insert_gateway_activity(gateway_id,  data) do
    Redix.command(@name, ["SET", "gatewaydata:#{gateway_id} EX time_to_live", data])
  end

end
