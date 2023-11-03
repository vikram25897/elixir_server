defmodule ElixirServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_server,
      version: "0.1.0",
      deps: deps(),
      escript: escript(),
      description: "Easily run http server from terminal",
      source_url: "https://github.com/vikram25897/elixir_server",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  def escript do
    [main_module: ElixirServer.CLI]
  end

  defp package do
    [
      licenses: ["Unlicense"],
      links: %{"GitHub" => "https://github.com/vikram25897/elixir_server"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:file_system, "~> 0.2"},
      {:bandit, "~> 1.0"},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev], runtime: false}
    ]
  end
end
