import Config

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
app_iot_port = System.fetch_env!("APP_IOT_PORT")
app_api_port = System.fetch_env!("APP_API_PORT")
app_hostname = System.fetch_env!("APP_HOSTNAME")
db_user = System.fetch_env!("DB_USER")
db_password = System.fetch_env!("DB_PASSWORD")
db_host = System.fetch_env!("DB_HOST")
elastic_search_host = System.fetch_env!("ELASTIC_SEARCH_HOST")

config :acqdat_iot, AcqdatIotWeb.Endpoint, server: true

config :acqdat_api, AcqdatApiWeb.Endpoint, server: true

# Configure Guardian
config :acqdat_api, AcqdatApiWeb.Guardian,
  issuer: "acqdat_api",
  secret_key: System.get_env("GUARDIAN_API_KEY")

# Configure Guardian
config :acqdat_iot, AcqdatIotWeb.Guardian,
  issuer: "acqdat_iot",
  secret_key: System.get_env("GUARDIAN_IOT_KEY")

config :acqdat_iot,
  app_port: app_iot_port

config :acqdat_api,
  app_port: app_api_port

config :acqdat_iot,
  app_hostname: app_hostname

config :acqdat_api,
  app_hostname: app_hostname

# Configure your database
config :acqdat_core, AcqdatCore.Repo,
  username: db_user,
  password: db_password,
  database: "acqdat_core_dev",
  hostname: db_host,
  pool_size: 40

config :tirexs, :uri, elastic_search_host
