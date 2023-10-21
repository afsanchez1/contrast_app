defmodule NewspaperScraper.Boundary.ScraperAPI do
  alias NewspaperScraper.Boundary.ScraperValidator
  alias NewspaperScraper.Boundary.ScraperManager

  def search_articles(request) do
    with :ok <- ScraperValidator.search_articles_errors(request),
         parsed_art_summs when is_list(parsed_art_summs) <-
           ScraperManager.search_articles(
             request.topic,
             request.page,
             request.limit
           ),
         do: parsed_art_summs,
         else: (error -> error)
  end

  def get_article(request) do
    with :ok <- ScraperValidator.get_article_errors(request),
         {:ok, parsed_art} <- ScraperManager.get_article(request.url),
         do: {:ok, parsed_art},
         else: (error -> error)
  end
end
