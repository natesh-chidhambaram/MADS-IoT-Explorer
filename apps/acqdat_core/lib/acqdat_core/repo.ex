defmodule AcqdatCore.Repo do
  use Ecto.Repo,
    otp_app: :acqdat_core,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
