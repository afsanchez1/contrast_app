defmodule NewspaperScraper.Core.ElPaisScraper do
  @behaviour Scraper
  use Tesla
  alias NewspaperScraper.Model.ArticleSummary
  alias NewspaperScraper.Model.Article
  alias NewspaperScraper.Model.Author

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
      e -> {:error, e}
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

  defp parse_art_header(parsed_art, html) do
    header_html =
      Floki.find(html, ".a_e_txt")

    parsed_header =
      Floki.traverse_and_update(header_html, fn
        {"div", _attrs, children} ->
          children

        {"h1", [{"class", "a_t"}], children} ->
          {:headline,
           children
           |> Enum.at(0)
           |> String.trim()}

        {"h2", [{"class", "a_st"}], children} ->
          {:subheadline,
           children
           |> Enum.at(0)
           |> String.trim()}

        _other ->
          nil
      end)

    Map.put(parsed_art, :headline, parsed_header[:headline])
    |> Map.put(:subheadline, parsed_header[:subheadline])
  end

  # -----------------------------------------------------------------------------------

  defp parse_art_authors(parsed_art, html) do
    authors_html = Floki.find(html, ".a_md_a")

    parsed_authors =
      Floki.traverse_and_update(authors_html, fn
        {"div", _attrs, children} ->
          children

        {"a", [{"href", url} | _], children} ->
          %Author{
            name:
              children
              |> Enum.at(0),
            url: url
          }

        _other ->
          nil
      end)

    Map.put(parsed_art, :authors, parsed_authors)
  end

  # -----------------------------------------------------------------------------------

  defp parse_art_date(parsed_art, html) do
    date_html = Floki.find(html, ".a_md_f")

    parsed_date_time =
      Floki.traverse_and_update(date_html, fn
        {"div", _attrs, children} ->
          children

        {"span", _attrs, children} ->
          children

        {"time", attrs, _children} ->
          {"data-date", d_t} =
            Enum.find(attrs, fn
              {"data-date", _} -> true
              _other -> false
            end)

          {:ok, date_time, offset} = DateTime.from_iso8601(d_t)
          {:date_time, DateTime.to_iso8601(date_time, :extended, offset)}

        _other ->
          nil
      end)

    {:date_time, p_d_t} =
      Enum.find(parsed_date_time, fn
        {:date_time, _} -> true
        _other -> false
      end)

    Map.put(parsed_art, :date_time, p_d_t)
  end

  # -----------------------------------------------------------------------------------

  defp parse_art_body(parsed_art, html) do
    body_html = Floki.find(html, ".a_c")

    parsed_body =
      Floki.traverse_and_update(body_html, fn
        {"div", [{"id", "les"}], _} ->
          nil

        {"div", _attrs, children} ->
          children

        {"h3", _attrs, children} ->
          %{h3: Enum.at(children, 0)}

        {"p", _attrs, children} ->
          parse_paragraph(children)

        {"a", _attrs, children} ->
          children

        _other ->
          nil
      end)

    Map.put(parsed_art, :body, parsed_body)
  end

  # -----------------------------------------------------------------------------------

  defp parse_paragraph(p_html) do
    parsed_paragraph =
      Floki.traverse_and_update(p_html, fn
        {"a", _attrs, [""]} ->
          nil

        {"a", _attrs, children} ->
          Enum.at(children, 0)

        "" ->
          nil

        p_text ->
          p_text
      end)
      |> Enum.join("")

    case parsed_paragraph do
      "" -> nil
      other -> %{p: other}
    end
  end
end
