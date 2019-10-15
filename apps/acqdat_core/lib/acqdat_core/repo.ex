defmodule AcqdatCore.Repo do
  use Ecto.Repo,
    otp_app: :acqdat_core,
    adapter: Ecto.Adapters.Postgres
end
