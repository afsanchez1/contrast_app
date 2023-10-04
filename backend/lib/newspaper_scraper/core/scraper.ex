defmodule Scraper do
  alias NewspaperScraper.Model.Author, as: Author
  alias NewspaperScraper.Model.Topic, as: Topic
  alias NewspaperScraper.Model.ArticleSummary, as: ArticleSummary
  alias NewspaperScraper.Model.Article, as: Article

  @type url :: String.t()
  @type html_doc :: String.t()

  @doc """
  Searches articles based on a topic
  """
  @callback search_articles(topic :: String.t(), page :: integer(), limit :: integer()) ::
              {:ok, list(struct())} | {:error, atom()}

  @doc """
  Parses the search results to a JSON
  """
  @callback parse_search_results(res :: {:ok, list(struct())} | {:error, atom()}) ::
              list(ArticleSummary)

  @doc """
  Gets the article HTML document
  """
  @callback get_article(url :: url()) :: {:ok, {html_doc(), url()}} | {:error, atom()}

  @doc """
  Converts the article HTML to a JSON
  """
  @callback parse_article(res :: {:ok, {html_doc(), url()}} | {:error, atom()}) ::
              %Article{
                newspaper: <<_::64>>,
                topic: %Topic{name: String.t(), url: url()},
                headline: String.t(),
                subheadline: String.t(),
                authors: list(Author),
                date_time: String.t(),
                location: String.t(),
                body: list(String.t()),
                url: url()
              }
              | {:error, atom()}
end
