defmodule NewspaperScraper.Core.Scraper do
  alias NewspaperScraper.Model.Author
  alias NewspaperScraper.Model.ArticleSummary
  alias NewspaperScraper.Model.Article

  @type url :: String.t()
  @type html_doc :: String.t()

  @doc """
  Returns the name of the scraper
  """
  @callback get_scraper_name() :: String.t()

  @doc """
  Checks if the url belongs to the scraper
  """
  @callback scraper_check(url :: url()) :: :ok | {:error, any()}

  @doc """
  Searches articles based on a topic
  """
  @callback search_articles(topic :: String.t(), page :: integer(), limit :: integer()) ::
              {:ok, list(struct())} | {:error, any()}

  @doc """
  Parses search results
  """
  @callback parse_search_results(articles :: list(struct())) ::
              {:ok, list(ArticleSummary)} | {:error, any()}

  @doc """
  Gets the article HTML
  """
  @callback get_article(url :: url()) :: {:ok, {html_doc(), url()}} | {:error, any()}

  @doc """
  Parses the article HTML
  """
  @callback parse_article(article :: html_doc(), url :: url()) ::
              %Article{
                newspaper: <<_::64>>,
                headline: String.t(),
                subheadline: String.t(),
                authors: list(Author),
                last_date_time: String.t(),
                # TODO Actualizar esto
                body: list(String.t()),
                url: url()
              }
              | {:error, any()}
end
