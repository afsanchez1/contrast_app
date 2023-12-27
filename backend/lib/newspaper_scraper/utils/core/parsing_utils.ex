defmodule NewspaperScraper.Utils.Core.ParsingUtils do
  alias NewspaperScraper.Model.Article
  alias NewspaperScraper.Core.ScraperParser
  alias NewspaperScraper.Core.ScraperParser

  @moduledoc """
  Parsing utilities for the scrapers
  """

  @doc """
  Tries to find an element using a selector
  """
  @spec find_element(ScraperParser.html_tree(), list()) ::
          {:ok, ScraperParser.html_tree()} | {:error, :not_found}
  def find_element(_html, []) do
    {:error, :not_found}
  end

  def find_element(html, [selector | t]) do
    case Floki.find(html, selector) do
      [] -> find_element(html, t)
      found -> {:ok, found}
    end
  end

  @doc """
  Transforms HTML text children
  """
  @spec transform_text_children(list()) :: String.t()
  def transform_text_children(children) do
    children
    |> Floki.text()
    |> String.trim()
  end

  @doc """
  Transforms a list of a HTML attributes into a map
  """
  @spec transform_attributes(list()) :: map()
  def transform_attributes(attrs), do: Map.new(attrs)

  @doc """
  Tries to find elements and calls the parsing functions when found
  """
  @spec parse(map(), atom(), ScraperParser.html_tree(), scraper :: module()) :: map()
  def parse(parsed_art, fun, html, scraper) do
    selectors = scraper.get_selectors(fun)

    case find_element(html, selectors) do
      {:error, :not_found} ->
        Map.put(parsed_art, fun, {:error, "HTML not found"})

      found_html ->
        case fun do
          :parse_art_header -> scraper.parse_art_header(parsed_art, found_html)
          :parse_art_authors -> scraper.parse_art_authors(parsed_art, found_html)
          :parse_art_date -> scraper.parse_art_date(parsed_art, found_html)
          :parse_art_body -> scraper.parse_art_body(parsed_art, found_html)
        end
    end
  end

  @doc """
  Checks for parsing errors
  """
  @spec fetch_parsed_art_errors(map()) :: list()
  def fetch_parsed_art_errors(parsed_art) do
    for {k, v} <- parsed_art do
      case v do
        {:error, e} -> {k, e}
        _ -> nil
      end
    end
    |> Enum.filter(fn elem -> elem !== nil end)
  end

  @doc """
  Converts parsed html to our defined Article struct
  """
  @spec html_to_article(html :: ScraperParser.html_tree(), url :: String.t(), scraper :: module()) ::
          {:ok, Article.t()} | {:error, any()}
  def html_to_article(html, url, scraper) do
    temp_art =
      %{}
      |> parse(:parse_art_header, html, scraper)
      |> parse(:parse_art_authors, html, scraper)
      |> parse(:parse_art_date, html, scraper)
      |> parse(:parse_art_body, html, scraper)

    case fetch_parsed_art_errors(temp_art) do
      [] ->
        {:ok,
         %Article{
           newspaper: scraper.get_newspaper_name(),
           headline: temp_art.headline,
           subheadline: temp_art.subheadline,
           authors: temp_art.authors,
           last_date_time: temp_art.date_time,
           body: temp_art.body,
           url: url
         }}

      errors ->
        {:error, errors}
    end
  end

  @doc """
  Returns a normalized name string

  ## Examples

      iex> normalize_name("JOHN DOE")
      "John Doe"
  """
  @spec normalize_name(String.t()) :: String.t()
  def normalize_name(name) do
    name
    |> String.split(" ", trim: true)
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join(" ")
  end
end
