use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :acqdat_iot, AcqdatApiWeb.Endpoint,
  http: [port: 4003],
  server: false

config :acqdat_api, AcqdatIotWeb.Endpoint,
  http: [port: 4004],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :acqdat_core, AcqdatCore.Repo,
  username: "postgres",
  password: "postgres",
  database: "acqdat_core_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :acqdat_core, AcqdatCore.Mailer, adapter: Bamboo.TestAdapter
