defmodule Tongue.MixProject do
  use Mix.Project

  def project do
    [
      app: :tongue,
      version: "2.2.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Tongue",
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [
      mod: {Tongue.App, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2", only: [:dev, :test]},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:nx, "~> 0.1.0-dev", github: "elixir-nx/nx", branch: "main", sparse: "nx"}
    ]
  end

  defp description do
    "Elixir port of Nakatani Shuyo's natural language detector"
  end

  defp package do
    [
      name: :tongue,
      files: ~w(lib/tongue* priv mix.exs README* LICENSE*),
      maintainers: ["Danila Poyarkov"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/abiko-search/tongue"}
    ]
  end
end
