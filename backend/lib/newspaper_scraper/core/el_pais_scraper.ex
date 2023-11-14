defmodule NewspaperScraper.Core.ElPaisScraper do
  @moduledoc """
  This module contains all the logic needed for scraping https://elpais.com
  """
  alias NewspaperScraper.Core.Scraper
  alias NewspaperScraper.Utils.Core.ParsingUtils
  alias NewspaperScraper.Model.ArticleSummary
  alias NewspaperScraper.Model.Article
  alias NewspaperScraper.Model.Author

  @behaviour Scraper

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

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def scraper_check(url) do
    case String.contains?(url, "elpais.com") do
      true -> :ok
      false -> {:error, "invalid url"}
    end
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def get_selectors({fun, _arity}) do
    selectors = %{
      check_premium: ["#ctn_freemium_article", "#ctn_premium_article"],
      parse_art_header: [".a_e_txt", ".articulo-titulares"],
      parse_art_authors: [".a_md_a", ".autor-texto"],
      parse_art_date: [".a_md_f", ".articulo-datos"],
      parse_art_body: [".a_c", ".articulo-cuerpo"]
    }

    selectors[fun]
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def search_articles(topic, page, limit) do
    query =
      """
         {\"q\":\"#{topic}\",
         \"page\":#{page + 1},
         \"limit\":#{limit},
         \"language\":\"es\"}
      """

    url = Tesla.build_url(@api_url, query: query)
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
          is_premium = search_check_premium(article["url"])

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

  # -----------------------------------------------------------------------------------

  # Checks if the articles found are premium
  @spec search_check_premium(url :: String.t()) :: true | false
  defp search_check_premium(url) do
    with {:ok, {body, _url}} <- get_article(url),
         {:ok, html} <- parse_document(body) do
      check_premium(html)
    else
      # If we cannot determine if the article is premium, we assume it is (for security reasons)
      _e -> true
    end
  end

  # -----------------------------------------------------------------------------------

  #  Checks if an article is premium
  @spec check_premium(html :: Scraper.html_tree()) :: true | false
  def check_premium(html) do
    selectors = get_selectors(__ENV__.function)

    case ParsingUtils.find_element(html, selectors) do
      {:error, :not_found} -> false
      _other -> true
    end
  end

  # ===================================================================================

  @impl Scraper
  def get_article(url) do
    case Tesla.get(@client, url) do
      {:ok, res} -> {:ok, {res.body, url}}
      {:error, err} -> {:error, err}
    end
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_article(html_doc, url) do
    with {:ok, html} <- parse_document(html_doc),
         false <- check_premium(html),
         {:ok, parsed_html} <- html_to_article(html, url) do
      {:ok, parsed_html}
    else
      {:error, e} -> {:error, e}
      true -> {:error, "forbidden content"}
    end
  end

  defp parse_document(html_doc), do: Floki.parse_document(html_doc)

  # -----------------------------------------------------------------------------------

  # Converts parsed html to our defined Article struct
  @spec html_to_article(html :: Scraper.html_tree(), url :: String.t()) ::
          {:ok, Article.t()} | {:error, any()}
  defp html_to_article(html, url) do
    temp_art =
      %{}
      |> parse_art_header(html)
      |> parse_art_authors(html)
      |> parse_art_date(html)
      |> parse_art_body(html)

    case temp_art.body do
      # If the article body couldn't be parsed, it doesn't make sense to send the rest of the info
      %{error: e} ->
        {:error, e}

      _other ->
        {:ok,
         %Article{
           newspaper: @newspaper_name,
           headline: temp_art.headline,
           subheadline: temp_art.subheadline,
           authors: temp_art.authors,
           last_date_time: temp_art.date_time,
           body: temp_art.body,
           url: url
         }}
    end
  end

  # -----------------------------------------------------------------------------------

  # Parses the article header (title and subtitle) and appends the result to the parsed_art map
  @spec parse_art_header(parsed_art :: map(), html :: Scraper.html_tree()) :: map()
  defp parse_art_header(parsed_art, html) do
    selectors = get_selectors(__ENV__.function)

    case ParsingUtils.find_element(html, selectors) do
      {:error, :not_found} ->
        parsed_art
        |> Map.put(:headline, %{error: "headline not found"})
        |> Map.put(:subheadline, %{error: "subheadline not found"})

      header_html ->
        parsed_header =
          Floki.traverse_and_update(header_html, fn
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
  end

  # -----------------------------------------------------------------------------------

  # Parses the article authors and appends the result to the parsed_art map
  @spec parse_art_authors(parsed_art :: map(), html :: Scraper.html_tree()) :: map()
  defp parse_art_authors(parsed_art, html) do
    selectors = get_selectors(__ENV__.function)

    case ParsingUtils.find_element(html, selectors) do
      {:error, :not_found} ->
        Map.put(parsed_art, :authors, %{error: "authors not found"})

      authors_html ->
        parsed_authors =
          Floki.traverse_and_update(authors_html, fn
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
  end

  # Builds the author url in case it comes incomplete
  @spec build_author_url(url :: String.t()) :: String.t()
  defp build_author_url(url) do
    case String.contains?(url, @base_url) do
      true -> url
      false -> "https://" <> @base_url <> url
    end
  end

  # -----------------------------------------------------------------------------------

  # Parses the article date and appends the result to the parsed_art map
  @spec parse_art_date(parsed_art :: map(), html :: Scraper.html_tree()) :: map()
  defp parse_art_date(parsed_art, html) do
    selectors = get_selectors(__ENV__.function)

    case ParsingUtils.find_element(html, selectors) do
      {:error, :not_found} ->
        Map.put(parsed_art, :date_time, %{error: "date_time not found"})

      date_html ->
        parsed_date_time =
          Floki.traverse_and_update(date_html, fn
            {"time", attrs, _children} ->
              transformed_attrs = ParsingUtils.transform_attributes(attrs)
              date_time = transformed_attrs["datetime"]
              parse_article_date_time(date_time)

            {_other, _attrs, children} ->
              children

            _other ->
              nil
          end)

        Map.put(parsed_art, :date_time, parsed_date_time[:date_time])
    end
  end

  # Check HTML datetime attr is formatted as expected
  @spec parse_article_date_time(date_time :: String.t()) :: {:date_time, any()}
  defp parse_article_date_time(date_time) do

    case DateTime.from_iso8601(date_time) do
      {:ok, date_time, offset} ->
        {:date_time, DateTime.to_iso8601(date_time, :extended, offset)}

      {:error, e} ->
        {:date_time, %{error: e}}
    end
  end

  # -----------------------------------------------------------------------------------

  # Parses the article body, filters it and appends the result to the parsed_art map
  @spec parse_art_body(parsed_art :: map(), html :: Scraper.html_tree()) :: map()
  defp parse_art_body(parsed_art, html) do
    selectors = get_selectors(__ENV__.function)

    case ParsingUtils.find_element(html, selectors) do
      {:error, :not_found} ->
        Map.put(parsed_art, :body, %{error: "body not found"})

      body_html ->
        parsed_body =
          Floki.traverse_and_update(body_html, fn
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
               String.contains?(text, "Publicaciones nuevas"))

      text ->
        not is_binary(text)
    end)
  end
end
