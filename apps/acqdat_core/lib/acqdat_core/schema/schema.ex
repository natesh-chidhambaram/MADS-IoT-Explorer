defmodule AcqdatCore.Schema do
  @moduledoc """
  Interface for DB related rules.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      @timestamps_opts [type: :utc_datetime]
      alias AcqdatCore.Repo

      @spec permalink(integer) :: binary
      def permalink(bytes_count) do
        bytes_count
        |> :crypto.strong_rand_bytes()
        |> Base.url_encode64(padding: false)
      end
    end
  end
end
