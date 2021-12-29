defmodule Cockpit.MixProject do
  use Mix.Project

  def project do
    [
      app: :cockpit,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Cockpit.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.10"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:params, "~> 2.0"},
      {:bamboo, github: "thoughtbot/bamboo"},
      {:plug_cowboy, "~> 2.0"},
      {:guardian, "~> 2.0"},
      {:comeonin, "~> 4.1.1"},
      {:argon2_elixir, "~> 1.2"},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
