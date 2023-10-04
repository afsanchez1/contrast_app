defmodule NewspaperScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :newspaper_scraper,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.34.3"},
      {:tesla, "~> 1.7"},
      {:jason, "~> 1.4.1"}
    ]
  end
end