defmodule Squeeze.Mixfile do
  use Mix.Project

  def project do
    [
      app: :squeeze,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
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
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_active_link, "~> 0.2.1"},
      {:turbolinks, "~> 0.3.4"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:ordinal, "~> 0.1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:strava, git: "https://github.com/slashdotdash/strava.git", branch: "master"},
      {:timex, "~> 3.3"},
      {:guardian, "~> 1.0"},
      {:browser, "~> 0.1.0"},
      {:ecto_enum, "~> 1.1"},
      {:stripity_stripe, "~> 2.2.2"},
      {:httpoison, "~> 1.5"},
      {:set_locale, "~> 0.2.4"},
      {:bamboo, "~> 1.2"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:ex_machina, "~> 2.1", only: :test},
      {:faker, "~> 0.9", only: :test},
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
      "compile": ["compile --warnings-as-errors"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
