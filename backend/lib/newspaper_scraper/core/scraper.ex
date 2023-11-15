defmodule NewspaperScraper.Core.Scraper do
  @moduledoc """
  This module implements the scraper behaviour
  """
  alias NewspaperScraper.Model.ArticleSummary
  alias NewspaperScraper.Model.Article

  @type selector :: Floki.css_selector()
  @type html_tree :: Floki.html_tree()

  @doc """
  Returns the name of the scraper
  """
  @callback get_scraper_name() :: String.t()

  @doc """
  Checks if the url belongs to the scraper
  """
  @callback scraper_check(url :: String.t()) :: :ok | {:error, any()}

  @doc """
  Provides the selectors needed for a specific function
  """
  @callback get_selectors(function :: atom()) :: list(selector()) | nil

  @doc """
  Searches articles based on a topic
  """
  @callback search_articles(topic :: String.t(), page :: integer(), limit :: integer()) ::
              {:ok, list(map())} | {:error, any()}

  @doc """
  Parses search results
  """
  @callback parse_search_results(articles :: list(map())) ::
              {:ok, list(ArticleSummary.t())} | {:error, any()}

  @doc """
  Requests the article HTML
  """
  @callback get_article(url :: String.t()) ::
              {:ok, {html_doc :: binary(), url :: String.t()}} | {:error, any()}

  @doc """
  Parses the article HTML
  """
  @callback parse_article(article :: binary(), url :: String.t()) ::
              {:ok, Article.t()} | {:error, any()}
end
