defmodule Squeeze.Mixfile do
  use Mix.Project

  def project do
    [
      app: :squeeze,
      version: "0.0.1",
      elixir: "~> 1.14.2",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],

      # Docs
      name: "OpenPace",
      source_url: "https://github.com/edance/openpace",
      homepage_url: "https://www.openpace.co",
      docs: [
        # main: "OpenPace", # The main page in the docs
        # logo: "path/to/logo.png",
        output: "priv/static/docs",
        javascript_config_path: nil,
        extras: ["README.md", "/docs/machine_learning.md"]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Squeeze.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/factories"]
  defp elixirc_paths(:dev), do: ["lib", "test/support/factory.ex", "test/factories"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.11"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.17.11"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:gettext, "~> 0.20"},
      {:ordinal, "~> 0.1.0"},
      {:plug_cowboy, "~> 2.5"},
      {:plug, "~> 1.7"},
      {:strava, git: "https://github.com/edance/strava.git", ref: "0942445666e7bab56d128343c36be0ef5bee468f"},
      {:timex, "~> 3.3"},
      {:guardian, "~> 2.3.0"},
      {:browser, "~> 0.4.4"},
      {:polyline, "~> 1.3"},
      {:stripity_stripe, "~> 2.12.0"},
      {:httpoison, "~> 1.5"},
      {:set_locale, "~> 0.2.9"},
      {:bamboo, "~> 1.2"},
      {:oauth2, "~> 0.9"},
      {:argon2_elixir, "~> 2.0"},
      {:number, "~> 1.0.0"},
      {:tesla, "~> 1.5.0"},
      {:hackney, "~> 1.18.1"},
      {:jason, "~> 1.4"},
      {:sma, "~> 0.1"},
      {:html_sanitize_ex, "~> 1.4.0"},
      {:algolia, "~> 0.8.0"},
      {:cors_plug, "~> 2.0"},
      {:ex_machina, "~> 2.7"},
      {:quantum, "~> 3.0"},
      {:slack, "~> 0.23.5"},
      {:new_relic_agent, "~> 1.0"},
      {:redirect, "~> 0.4.0"},
      {:csv, "~> 3.0"},
      {:erlport, "~> 0.10.1"},
      {:poolboy, "~> 1.5"},
      {:sweet_xml, "~> 0.7.1"},
      {:ex_doc, "~> 0.27", runtime: false},
      {:nx, "~> 0.3.0"},
      {:axon, "~> 0.2.0"},
      {:kino, "~> 0.6.2", only: :dev},
      {:explorer, "~> 0.2.0", only: :dev},
      {:distance, "~> 0.2.2", only: :dev},
      {:credo, "~> 1.6.1", only: [:dev, :test], runtime: false},
      {:faker, "~> 0.9", only: [:dev, :test]},
      {:floki, ">= 0.30.0", only: :test},
      {:excoveralls, "~> 0.14.6", only: :test},
      {:mox, "~> 0.4", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd --cd assets yarn install"],
      compile: ["compile --warnings-as-errors"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.deploy": ["cmd --cd assets yarn install", "cmd --cd assets node build.js --deploy", "phx.digest"]
    ]
  end
end
