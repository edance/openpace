defmodule Squeeze.Mixfile do
  use Mix.Project

  def project do
    [
      app: :squeeze,
      version: "0.0.1",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
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
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.6"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_active_link, "~> 0.2.1"},
      {:turbolinks, "~> 1.0.1"},
      {:gettext, "~> 0.11"},
      {:ordinal, "~> 0.1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:strava, "~> 1.0"},
      {:timex, "~> 3.3"},
      {:guardian, "~> 2.0"},
      {:browser, "~> 0.4.4"},
      {:ecto_enum, "~> 1.1"},
      {:stripity_stripe, "~> 2.7.0"},
      {:httpoison, "~> 1.5"},
      {:set_locale, "~> 0.2.4"},
      {:bamboo, "~> 1.2"},
      {:oauth2, "~> 0.9"},
      {:argon2_elixir, "~> 2.0"},
      {:earmark, "~> 1.2"},
      {:number, "~> 1.0.0"},
      {:tesla, "~> 1.3.0"},
      {:hackney, "~> 1.15.0"},
      {:jason, "~> 1.1"},
      {:sma, "~> 0.1"},
      {:sweet_xml, "~> 0.3", only: :dev},
      {:distance, "~> 0.2.2", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.1", only: :test},
      {:faker, "~> 0.9", only: [:dev, :test]},
      {:excoveralls, "~> 0.9", only: :test},
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
      compile: ["compile --warnings-as-errors"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
