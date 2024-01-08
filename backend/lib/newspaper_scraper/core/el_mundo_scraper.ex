defmodule NewspaperScraper.Core.ElMundoScraper do
  @moduledoc """
  This module contains all the logic needed for scraping https://www.elmundo.es/
  """
  alias NewspaperScraper.Core.ElMundoScraper
  alias NewspaperScraper.Core.ScraperParser
  alias NewspaperScraper.Core.Scraper
  alias NewspaperScraper.Utils.Core.ParsingUtils
  alias NewspaperScraper.Core.ScraperCommImpl
  alias NewspaperScraper.Model.ArticleSummary
  alias NewspaperScraper.Model.Author

  @behaviour Scraper
  @behaviour ScraperParser

  @scraper_name "el-mundo"
  @newspaper_name "El Mundo"

  # @base_url Application.compile_env(:newspaper_scraper, :el_mundo_base_url)
  @api_url Application.compile_env(:newspaper_scraper, :el_mundo_api_url)

  @middleware [
    Tesla.Middleware.FollowRedirects,
    {Tesla.Middleware.Headers,
     [
       {"user-agent",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"},
       {"accept", "text/html"}
     ]},
    Tesla.Middleware.DecompressResponse
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
    ScraperCommImpl.comm_scraper_check(url, "elmundo.es")
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def get_selectors(function) do
    selectors = %{
      parse_search_results: [".lista_resultados"],
      check_premium: [".ue-c-article__premium-tag"],
      parse_art_header: [".ue-c-article"],
      parse_art_authors: [".ue-c-article__byline-name"],
      parse_art_date: [".ue-c-article__publishdate"],
      parse_art_body: []
    }

    selectors[function]
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def search_articles(topic, page, limit) do
    req_page =
      cond do
        page === 0 -> 1
        page === 1 -> limit + page
        true -> 1 + limit * (page - 1)
      end

    #  We have to transform it to latin1 encoding for elmundo server to understand
    {:ok, parsed_topic} = Codepagex.from_string(topic, :iso_8859_1)

    request = [
      q: parsed_topic,
      t: 1,
      # Index
      i: req_page,
      n: limit,
      fd: 0,
      td: 0,
      #  Coincidence ratio
      w: 80,
      #  Order by date = 1, order by coincidence = 0
      s: 1,
      no_acd: 1,
      b_avanzada: "elmundoes"
    ]

    url =
      Tesla.build_url(@api_url, request)

    case Tesla.get(@client, url) do
      # If no errors, transform the body into a string
      {:ok, res} -> {:ok, transform_body_into_html(res.body)}
      {:error, err} -> {:error, err}
    end
  end

  # Response comes in binary, so we transform it to a string
  @spec transform_body_into_html(body :: binary()) :: String.t()
  defp transform_body_into_html(body) do
    body
    |> :binary.bin_to_list()
    |> List.to_string()
    |> String.replace(~r/\n/, "")
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_search_results(articles) do
    selectors = get_selectors(:parse_search_results)

    with {:ok, html} <- Floki.parse_document(articles),
         {:ok, found_html} <- ParsingUtils.find_element(html, selectors),
         do: parse_search_results_html(found_html),
         else: (error -> error)
  end

  # Auxiliar function for parsing search results
  @spec parse_search_results_html(html :: ScraperParser.html_tree()) ::
          [
            ArticleSummary.t()
          ]
          | {:error, any()}
  defp parse_search_results_html(html) do
    try do
      Floki.traverse_and_update(html, fn
        {"div", _attrs, children} ->
          children

        {"ul", _attrs, children} ->
          children

        {"li", _attrs, []} ->
          nil

        {"li", _attrs, [{:date, date_str} | t]} ->
          [{:date, date_str} | t]

        {"li", [], children} ->
          {:art_summ, children}

        {"h3", _attrs, children} ->
          children

        {"a", [{"href", url}], children} ->
          [{:url, url}, {:title, ParsingUtils.transform_text_children(children)}]

        {"p", [], children} ->
          {:excerpt, ParsingUtils.transform_text_children(children)}

        {"p", _attrs, _children} ->
          nil

        # TODO: Quitar esto
        {"span", [{"class", "fecha"}], [date]} ->
          {:date, date}

        {"span", [{"class", "firma"}], children} ->
          children

        {"strong", [{"class", "autor"}], [author_name]} ->
          {:author,
           [
             %Author{
               name: ParsingUtils.normalize_name(author_name),
               url: nil
             }
           ]}

        {"strong", [], [children]} ->
          children

        {"strong", _attrs, _children} ->
          nil

        {:comment, _comment} ->
          nil

        other ->
          other
      end)
      |> build_article_summs()
    rescue
      _e ->
        {:error, "parsing error"}
    end
  end

  # A function for building the Article Summary list
  @spec build_article_summs(raw_art_summs :: list()) :: [
          ArticleSummary.t()
        ]
  defp build_article_summs(raw_art_summs) do
    Enum.map(raw_art_summs, fn {:art_summ, contents} ->
      contents_map =
        Map.new(contents)

      url = contents_map[:url]

      %ArticleSummary{
        newspaper: get_newspaper_name(),
        # TODO: Pick it from article
        authors: contents_map[:author],
        title: contents_map[:title],
        excerpt: contents_map[:excerpt],
        # TODO: Pick it from article
        date_time: contents_map[:date],
        url: url,
        # TODO: Pick it from article
        is_premium: ParsingUtils.search_check_premium(url, ElMundoScraper)
      }
    end)
  end

  # ===================================================================================

  @impl Scraper
  def get_article(url) do
    case Tesla.get(@client, url) do
      {:ok, res} -> {:ok, {transform_body_into_html(res.body), url}}
      {:error, err} -> {:error, err}
    end
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_article(html_doc, url) do
    ScraperCommImpl.comm_parse_article(html_doc, url, ElMundoScraper)
  end

  # -----------------------------------------------------------------------------------

  @spec find_and_parse_text(
          html :: Floki.html_tree(),
          selectors :: list(Floki.css_selector())
        ) :: content :: String.t()
  defp find_and_parse_text(html, selectors) do
    case ParsingUtils.find_element(html, selectors) do
      {:error, _e} -> nil
      {:ok, found_html} -> ParsingUtils.transform_text_children(found_html)
    end
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def parse_art_header(parsed_art, html) do
    parsed_header =
      [
        {:headline, find_and_parse_text(html, [".ue-c-article__headline"])},
        {:subheadline,
         find_and_parse_text(html, [
           ".ue-c-article__standfirst",
           ".ue-c-article__card-body"
         ])}
      ]

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
          [h | _t] = children

          if is_binary(h) do
            Enum.map(children, fn child ->
              %Author{
                name: ParsingUtils.normalize_name(child),
                url: nil
              }
            end)
          else
            children
          end

        {"a", attrs, children} ->
          transformed_attrs = ParsingUtils.transform_attributes(attrs)
          url = transformed_attrs["href"]

          name =
            ParsingUtils.transform_text_children(children)
            |> ParsingUtils.normalize_name()

          %Author{
            name: name,
            url: url
          }

        other ->
          other
      end)

    Map.put(parsed_art, :authors, parsed_authors)
  end

  # -----------------------------------------------------------------------------------

  @impl ScraperParser
  def parse_art_date(parsed_art, html) do
    ScraperCommImpl.comm_parse_art_date(parsed_art, html)
  end
end
