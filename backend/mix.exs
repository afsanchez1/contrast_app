defmodule NewspaperScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :newspaper_scraper,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: test_coverage()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NewspaperScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.34.3"},
      {:tesla, "~> 1.7"},
      {:jason, "~> 1.4.1"},
      {:gen_stage, "~> 1.2"},
      {:plug_cowboy, "~> 2.6"}
    ]
  end

  defp aliases do
    [
      test: "test --no-start --trace --cover"
    ]
  end

  defp test_coverage do
    [
      ignore_modules: [
        NewspaperScraper.Application,
        NewspaperScraper.Core.Scraper,
        NewspaperScraper.Model.Article,
        NewspaperScraper.Model.ArticleSummary,
        NewspaperScraper.Model.Author,
        Jason.Encoder.NewspaperScraper.Model.Article,
        Jason.Encoder.NewspaperScraper.Model.ArticleSummary,
        Jason.Encoder.NewspaperScraper.Model.Author
      ]
    ]
  end
end
