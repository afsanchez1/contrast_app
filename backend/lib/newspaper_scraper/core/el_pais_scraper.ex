defmodule NewspaperScraper.Core.ElPaisScraper do
  alias NewspaperScraper.Core.Scraper
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
    {Tesla.Middleware.BaseUrl, @base_url}
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

  defp parse_search_date_time(date_time) do
    dt = DateTime.from_unix(date_time, :second)

    case dt do
      {:ok, datetime} -> DateTime.to_iso8601(datetime, :extended)
      {:error, e} -> {:error, e}
    end
  end

  # -----------------------------------------------------------------------------------

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

  def check_premium(html) do
    selectors = ["#ctn_freemium_article", "#ctn_premium_article"]

    case find_element(html, selectors) do
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

  defp html_to_article(html, url) do
    temp_art =
      parse_art_header(%{}, html)
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

  defp find_element(_html, []) do
    {:error, :not_found}
  end

  defp find_element(html, [selector | t]) do
    case Floki.find(html, selector) do
      [] -> find_element(html, t)
      found -> found
    end
  end

  # -----------------------------------------------------------------------------------

  defp transform_text_children(children) do
    children
    |> Floki.text()
    |> String.trim()
  end

  # -----------------------------------------------------------------------------------

  def transform_attributes(attrs), do: Map.new(attrs)

  # -----------------------------------------------------------------------------------

  defp parse_art_header(parsed_art, html) do
    selectors = [".a_e_txt", ".articulo-titulares"]

    case find_element(html, selectors) do
      {:error, :not_found} ->
        parsed_art
        |> Map.put(:headline, %{error: "headline not found"})
        |> Map.put(:subheadline, %{error: "subheadline not found"})

      header_html ->
        parsed_header =
          Floki.traverse_and_update(header_html, fn
            {"h1", _attrs, children} ->
              {:headline, transform_text_children(children)}

            {"h2", _attrs, children} ->
              {:subheadline, transform_text_children(children)}

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

  defp parse_art_authors(parsed_art, html) do
    selectors = [".a_md_a", ".autor-texto"]

    case find_element(html, selectors) do
      {:error, :not_found} ->
        Map.put(parsed_art, :authors, %{error: "authors not found"})

      authors_html ->
        parsed_authors =
          Floki.traverse_and_update(authors_html, fn
            {"div", _attrs, children} ->
              children

            # When author has url
            {"a", attrs, children} ->
              transformed_attrs = transform_attributes(attrs)
              url = transformed_attrs["href"]

              %Author{
                name: transform_text_children(children),
                url: build_author_url(url)
              }

            {"span", [{"class", "autor-nombre"} | _r_attrs], children} ->
              children

            # When author doesn't have url
            {"span", _attrs, children} ->
              %Author{
                name: transform_text_children(children),
                url: nil
              }

            _other ->
              nil
          end)

        Map.put(parsed_art, :authors, parsed_authors)
    end
  end

  defp build_author_url(url) do
    case String.contains?(url, @base_url) do
      true -> url
      false -> "https://" <> @base_url <> url
    end
  end

  # -----------------------------------------------------------------------------------

  defp parse_art_date(parsed_art, html) do
    selectors = [".a_md_f", ".articulo-datos"]

    case find_element(html, selectors) do
      {:error, :not_found} ->
        Map.put(parsed_art, :date_time, %{error: "date_time not found"})

      date_html ->
        parsed_date_time =
          Floki.traverse_and_update(date_html, fn
            {"time", attrs, _children} ->
              transformed_attrs = transform_attributes(attrs)
              datetime = transformed_attrs["datetime"]

              # Check HTML datetime attr is formatted as expected
              with {:ok, date_time, offset} <- DateTime.from_iso8601(datetime) do
                {:date_time, DateTime.to_iso8601(date_time, :extended, offset)}
              else
                _e -> {:date_time, %{error: "date_time format error"}}
              end

            {_other, _attrs, children} ->
              children

            _other ->
              nil
          end)

        Map.put(parsed_art, :date_time, parsed_date_time[:date_time])
    end
  end

  # -----------------------------------------------------------------------------------

  defp parse_art_body(parsed_art, html) do
    selectors = [".a_c", ".articulo-cuerpo"]

    case find_element(html, selectors) do
      {:error, :not_found} ->
        Map.put(parsed_art, :body, %{error: "body not found"})

      body_html ->
        parsed_body =
          Floki.traverse_and_update(body_html, fn
            {"div", _attrs, children} ->
              children

            {"h2", _attrs, children} ->
              %{h2: transform_text_children(children)}

            {"h3", _attrs, children} ->
              %{h3: transform_text_children(children)}

            {"a", _attrs, children} ->
              children

            {"i", _attrs, children} ->
              children

            {"b", _attrs, children} ->
              children

            {"p", _attrs, children} ->
              %{p: transform_text_children(children)}

            _other ->
              nil
          end)
          |> filter_body_content()

        Map.put(parsed_art, :body, parsed_body)
    end
  end

  # -----------------------------------------------------------------------------------

  defp filter_body_content(body) do
    Enum.filter(body, fn
      %{p: ""} ->
        false

      %{p: nil} ->
        false

      %{p: text} ->
        not (String.contains?(text, "Sigue toda la información de Cinco Días") or
               String.contains?(text, "apuntarte aquí para recibir nuestra newsletter semanal"))

      _other ->
        true
    end)
  end
end
