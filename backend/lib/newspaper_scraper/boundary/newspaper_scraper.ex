defmodule NewspaperScraper do
  alias NewspaperScraper.Boundary.ScraperValidator
  alias NewspaperScraper.Boundary.ScraperManager

  def search_articles(request) do
    with :ok <- ScraperValidator.search_articles_errors(request),
         :ok <-
           ScraperManager.search_articles(ScraperManager, request.topic, request.page, request.limit),
         do: :ok,
         else: (error -> error)
  end

  def get_article(request) do
    with :ok <- ScraperValidator.get_article_errors(request),
         :ok <- ScraperManager.get_article(request.url),
         do: :ok,
         else: (error -> error)
  end
end
