defmodule NewspaperScraper.Core.ElPaisScraper do
  @moduledoc """
  This module contains all the logic needed for scraping https://elpais.com
  """
  alias NewspaperScraper.Core.ElPaisScraper
  alias NewspaperScraper.Core.ScraperParser
  alias NewspaperScraper.Core.Scraper
  alias NewspaperScraper.Core.ScraperCommImpl
  alias NewspaperScraper.Utils.Core.ParsingUtils
  alias NewspaperScraper.Model.ArticleSummary
  alias NewspaperScraper.Model.Author

  @behaviour Scraper
  @behaviour ScraperParser

  @scraper_name "el-pais"
  @newspaper_name "El País"
  @base_url Application.compile_env(:newspaper_scraper, :el_pais_base_url)
  @api_url Application.compile_env(:newspaper_scraper, :el_pais_api_url)

  @middleware [
    Tesla.Middleware.JSON,
    {Tesla.Middleware.BaseUrl, @base_url},
    Tesla.Middleware.FollowRedirects
  ]
  @client Tesla.client(@middleware)

  # ===================================================================================

  @impl Scraper
  def get_scraper_name, do: @scraper_name

  @impl Scraper
  def get_newspaper_name, do: @newspaper_name

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def scraper_check(url) do
    ScraperCommImpl.comm_scraper_check(url, "elpais.com")
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def get_selectors(function) do
    selectors = %{
      check_premium: ["#ctn_freemium_article", "#ctn_premium_article"],
      parse_art_header: [".a_e_txt", ".articulo-titulares"],
      parse_art_authors: [".a_md_a", ".autor-texto"],
      parse_art_date: [".a_md_f", ".articulo-datos"],
      parse_art_body: [".a_c", ".articulo-cuerpo"]
    }

    selectors[function]
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def search_articles(topic, page, limit) do
    {:ok, query} =
      Jason.encode(%{q: topic, page: page + 1, limit: limit, language: "es"})

    url = Tesla.build_url(@api_url, query: query, _website: "el-pais")

    req = Tesla.get(@client, url)

    case req do
      {:ok, res} -> handle_response(res)
      {:error, err} -> {:error, err}
    end
  end

  defp handle_response(res) do
    case res.status do
      200 -> {:ok, res.body["articles"]}
      _ -> {:error, res.body}
    end
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_search_results(articles) do
    parsed_arts =
      Enum.map(
        articles,
        fn article ->
          date_time = parse_search_date_time(article["updatedTs"])
          authors = parse_search_authors(article["authors"])
          is_premium = ParsingUtils.search_check_premium(article["url"], ElPaisScraper)

          %ArticleSummary{
            newspaper: @newspaper_name,
            authors: authors,
            title: article["title"],
            excerpt: article["excerpt"],
            date_time: date_time,
            url: article["url"],
            is_premium: is_premium
          }
        end
      )

    case parsed_arts do
      [] -> {:error, "no articles found to parse"}
      [_ | _] -> {:ok, parsed_arts}
    end
  end

  # -----------------------------------------------------------------------------------

  # UpdatedTs comes in Unix seconds so we parse it to ISO 8601:2019 format
  @spec parse_search_date_time(date_time :: integer()) :: {:ok, String.t()} | {:error, atom()}
  defp parse_search_date_time(date_time) do
    dt = DateTime.from_unix(date_time, :second)

    case dt do
      {:ok, datetime} -> DateTime.to_iso8601(datetime, :extended)
      {:error, e} -> {:error, e}
    end
  end

  # -----------------------------------------------------------------------------------

  # Parses authors to our defined Authors struct
  @spec parse_search_authors(authors :: list(map())) :: list(Author.t()) | []
  defp parse_search_authors(authors) do
    Enum.map(
      authors,
      fn author ->
        %Author{
          name: author["name"],
          url: author["url"]
        }
      end
    )
  end

  # ===================================================================================

  @impl Scraper
  def get_article(url) do
    ScraperCommImpl.comm_get_article(@client, url)
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_article(html_doc, url) do
    ScraperCommImpl.comm_parse_article(html_doc, url, ElPaisScraper)
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def parse_art_header(parsed_art, html) do
    parsed_header =
      Floki.traverse_and_update(html, fn
        {"h1", _attrs, children} ->
          {:headline, ParsingUtils.transform_text_children(children)}

        {"h2", _attrs, children} ->
          {:subheadline, ParsingUtils.transform_text_children(children)}

        {_other, _attrs, children} ->
          children

        _other ->
          nil
      end)

    parsed_art
    |> Map.put(:headline, parsed_header[:headline])
    |> Map.put(:subheadline, parsed_header[:subheadline])
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def parse_art_authors(parsed_art, html) do
    parsed_authors =
      Floki.traverse_and_update(html, fn
        {"div", _attrs, children} ->
          children

        # When author has url
        {"a", attrs, children} ->
          transformed_attrs = ParsingUtils.transform_attributes(attrs)
          url = transformed_attrs["href"]

          %Author{
            name: ParsingUtils.transform_text_children(children),
            url: build_author_url(url)
          }

        {"span", [{"class", "autor-nombre"} | _r_attrs], children} ->
          children

        # When author doesn't have url
        {"span", _attrs, children} ->
          %Author{
            name: ParsingUtils.transform_text_children(children),
            url: nil
          }

        _other ->
          nil
      end)

    Map.put(parsed_art, :authors, parsed_authors)
  end

  # Builds the author url in case it comes incomplete
  @spec build_author_url(url :: String.t()) :: String.t()
  defp build_author_url(url) do
    case String.contains?(url, @base_url) do
      true -> url
      # TODO check if this is correct (maybe bug)
      false -> "https://" <> @base_url <> url
    end
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def parse_art_date(parsed_art, html) do
    ScraperCommImpl.comm_parse_art_date(parsed_art, html)
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def parse_art_body(parsed_art, html) do
    parsed_body =
      Floki.traverse_and_update(html, fn
        # Avoids picking more content than needed in live articles
        {"div", [{"id", "les"}], _children} ->
          nil

        {"div", _attrs, children} ->
          children

        {"h2", _attrs, children} ->
          %{h2: ParsingUtils.transform_text_children(children)}

        {"h3", _attrs, children} ->
          %{h3: ParsingUtils.transform_text_children(children)}

        {"a", _attrs, children} ->
          children

        {"i", _attrs, children} ->
          children

        {"em", _attrs, children} ->
          children

        {"b", _attrs, children} ->
          children

        {"strong", _attrs, children} ->
          children

        {"p", _attrs, children} ->
          %{p: ParsingUtils.transform_text_children(children)}

        _other ->
          nil
      end)
      |> filter_body_content()

    Map.put(parsed_art, :body, parsed_body)
  end

  # -----------------------------------------------------------------------------------

  # Filters unwanted content out from the parsed body
  @spec filter_body_content(body :: list()) :: list()
  defp filter_body_content(body) do
    Enum.filter(body, fn
      %{p: ""} ->
        false

      %{p: nil} ->
        false

      %{p: text} ->
        not (String.contains?(text, "Sigue toda la información de Cinco Días") or
               String.contains?(text, "nuestra newsletter semanal") or
               String.contains?(text, "EL PAÍS") or
               String.contains?(text, "Publicaciones nuevas") or
               String.contains?(text, "seguir"))

      text ->
        not is_binary(text)
    end)
  end
end
