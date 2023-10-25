defmodule NewspaperScraper.Core.ElPaisScraper do
  alias NewspaperScraper.Core.Scraper
  alias NewspaperScraper.Model.ArticleSummary
  alias NewspaperScraper.Model.Article
  alias NewspaperScraper.Model.Author

  @behaviour Scraper
  use Tesla

  @scraper_name "el-pais"
  @newspaper_name "El País"
  @el_pais_base_url "elpais.com"
  @el_pais_api "/pf/api/v3/content/fetch/enp-search-results"

  @middleware [
    Tesla.Middleware.JSON,
    {Tesla.Middleware.BaseUrl, @el_pais_base_url}
  ]
  @client Tesla.client(@middleware)

  # ===================================================================================

  @impl Scraper
  def get_scraper_name, do: @scraper_name

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def scraper_check(url) do
    case String.contains?(url, @el_pais_base_url) do
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
         \"page\":#{page},
         \"limit\":#{limit},
         \"language\":\"es\"}
      """

    url = Tesla.build_url("https://#{@el_pais_base_url}#{@el_pais_api}", query: query)

    case Tesla.get(@client, url) do
      {:ok, res} -> {:ok, res.body["articles"]}
      {:error, err} -> {:error, err}
    end
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_search_results(articles) do
    try do
      parsed_arts =
        Enum.map(
          articles,
          fn article ->
            date_time = parse_search_date_time(article["updatedTs"])
            authors = parse_search_authors(article["authors"])
            is_premium = check_premium(article["url"])

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

      {:ok, parsed_arts}
    rescue
      e -> {:error, e}
    end
  end

  # -----------------------------------------------------------------------------------

  defp parse_search_date_time(date_time) do
    DateTime.from_unix(date_time, :second)
    |> Tuple.to_list()
    |> Enum.at(1)
    |> DateTime.to_iso8601()
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

  defp check_premium(url) do
    with {:ok, {html_doc, _art_url}} <- get_article(url),
         {:ok, check} <- aux_check_premium(html_doc),
         do: check,
         else: (error -> error)
  end

  defp aux_check_premium(html_doc) do
    case parse_document(html_doc) do
      {:ok, _} -> {:ok, false}
      {:error, :forbbiden_content} -> {:ok, true}
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
    try do
      case parse_document(html_doc) do
        {:ok, html} -> {:ok, html_to_article(html, url)}
        {:error, err} -> {:error, err}
      end
    rescue
      _e -> {:error, "parsing error"}
    end
  end

  # -----------------------------------------------------------------------------------

  defp parse_document(html_doc) do
    {:ok, html} = Floki.parse_document(html_doc)
    premium_html = Floki.find(html, ".a_t_i-s")

    case premium_html do
      [] -> {:ok, html}
      _other -> {:error, :forbbiden_content}
    end
  end

  # -----------------------------------------------------------------------------------

  defp html_to_article(html, url) do
    temp_art =
      parse_art_header(%{}, html)
      |> parse_art_authors(html)
      |> parse_art_date(html)
      |> parse_art_body(html)

    %Article{
      newspaper: @newspaper_name,
      headline: temp_art.headline,
      subheadline: temp_art.subheadline,
      authors: temp_art.authors,
      last_date_time: temp_art.date_time,
      body: temp_art.body,
      url: url
    }
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
    case children do
      [] -> nil
      [text] -> String.trim(text)
      _other -> nil
    end |> dbg()
  end

  # -----------------------------------------------------------------------------------

  defp transform_attributes(attrs), do: Map.new(attrs)

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
            {"a", attrs, children} ->
              transformed_attrs = transform_attributes(attrs)
              url = transformed_attrs["href"]

              %Author{
                name: transform_text_children(children),
                url: build_author_url(url)
              }

            {_other, _attrs, children} ->
              children

            _other ->
              nil
          end)

        Map.put(parsed_art, :authors, parsed_authors)
    end
  end

  defp build_author_url(url) do
    case String.contains?(url, @el_pais_base_url) do
      true -> url
      false -> @el_pais_base_url <> url
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

            {"h3", _attrs, [children]} ->
              %{h3: transform_text_children([children])}

            {"h3", _attrs, children} ->
              text = Floki.text(children)
              %{h3: transform_text_children([text])}

            {"a", _attrs, children} ->
              children

            {"i", _attrs, children} ->
              children

            {"b", _attrs, children} ->
              children

            {"p", _attrs, children} ->
              parse_paragraph(children)

            {_other, _attrs, _children} ->
              nil

            _other ->
              nil
          end)

        Map.put(parsed_art, :body, parsed_body)
    end
    |> dbg()
  end

  # -----------------------------------------------------------------------------------

  defp parse_paragraph(p_html) do
    Floki.traverse_and_update(p_html, fn
      {"a", _attrs, children} ->
        transform_text_children(children)

      {"i", _attrs, children} ->
        transform_text_children(children)

      p_text ->
        transform_text_children([p_text])
    end)
    |> Enum.join("")
    |> String.trim()
    |> check_parsed_paragraph()
  end

  defp check_parsed_paragraph(parsed_paragraph) do
    case parsed_paragraph do
      "" -> nil
      other -> %{p: other}
    end
  end
end
