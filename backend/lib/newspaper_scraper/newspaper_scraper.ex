defmodule NewspaperScraper do
  alias NewspaperScraper.Boundary.ScraperValidator
  alias NewspaperScraper.Core.ElPaisScraper
  alias NewspaperScraper.Boundary.ScraperManager

  @scrapers [
    ElPaisScraper
  ]

  def start_newspaper_scraper() do
    GenServer.start_link(ScraperManager, @scrapers, name: ScraperManager)
  end

  def search_articles(fields) do
    with :ok <- ScraperValidator.search_articles_errors(fields),
         :ok <- GenServer.call(ScraperManager, {:search_articles, fields}, 10_000),
    do: :ok, else: (error -> error)
  end

  def get_article(fields) do
    with :ok <- ScraperValidator.get_article_errors(fields),
         :ok <- GenServer.call(ScraperManager, {:get_article, fields}, 10_000),
    do: :ok, else: (error -> error)
  end
end
