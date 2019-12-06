defmodule Tongue.MixProject do
  use Mix.Project

  def project do
    [
      app: :tongue,
      version: "1.0.2",
      elixir: "~> 1.7",
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
      extra_applications: [:logger, :poison]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev, :test], runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir port of Nakatani Shuyo's natural language detector"
  end

  defp package do
    [
      name: :tongue,
      files: ["lib/tongue*", "priv", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Danila Poyarkov"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/dannote/tongue"}
    ]
  end
end
