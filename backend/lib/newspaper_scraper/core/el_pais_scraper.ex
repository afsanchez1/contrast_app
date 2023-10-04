defmodule NewspaperScraper.Core.ElPaisScraper do
  @behaviour Scraper
  use Tesla
  alias NewspaperScraper.Model.ArticleSummary, as: ArticleSummary
  alias NewspaperScraper.Model.Article, as: Article
  alias NewspaperScraper.Model.Author, as: Author
  alias NewspaperScraper.Model.Topic, as: Topic

  @newspaper_name "El País"
  @el_pais_base_url "https://elpais.com"
  @el_pais_api "/pf/api/v3/content/fetch/enp-search-results"

  @middleware [
    Tesla.Middleware.JSON,
    {Tesla.Middleware.BaseUrl, @el_pais_base_url}
  ]
  @client Tesla.client(@middleware)

  # ===================================================================================

  @impl Scraper
  def search_articles(topic, page, limit) do
    query =
      """
         {\"q\":\"#{topic}\",
         \"page\":#{page},
         \"limit\":#{limit},
         \"language\":\"es\"}
      """

    url = Tesla.build_url(@el_pais_api, query: query)

    case Tesla.get(@client, url) do
      {:ok, res} -> {:ok, res.body["articles"]}
      {:error, err} -> {:error, err}
    end
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_search_results({:error, err}), do: {:error, err}

  @impl Scraper
  def parse_search_results({:ok, articles}) do
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
    {:ok, {html_doc, _art_url}} = get_article(url)

    case parse_document(html_doc) do
      {:ok, _} -> false
      {:error, :forbbiden_content} -> true
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
  def parse_article({:error, err}), do: {:error, err}

  @impl Scraper
  def parse_article({:ok, {html_doc, url}}) do
    case parse_document(html_doc) do
      {:ok, html} -> {:ok, html_to_article(html, url)}
      {:error, err} -> {:error, err}
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
      parse_header(%{}, html)
      |> parse_art_authors(html)
      |> parse_date_and_location(html)
      |> parse_body(html)

    %Article{
      newspaper: @newspaper_name,
      topic: temp_art.topic,
      headline: temp_art.headline,
      subheadline: temp_art.subheadline,
      authors: temp_art.authors,
      date_time: temp_art.date_time,
      location: temp_art.location,
      body: temp_art.body,
      url: url
    }
  end

  # -----------------------------------------------------------------------------------

  defp find_text(html) do
    Floki.text(html, sep: "-")
    |> String.split("-")
  end

  # -----------------------------------------------------------------------------------

  defp parse_header(parsed_art, html) do
    header_html = Floki.find(html, ".a_e_txt")
    header_text = find_text(header_html)

    topic =
      %Topic{
        name:
          Enum.at(header_text, 0)
          |> String.capitalize(),
        url:
          Floki.attribute(header_html, ".a_k_n", "href")
          |> Enum.at(0)
      }

    headline =
      Enum.at(header_text, 1)
      |> String.trim()

    subheadline =
      Enum.at(header_text, 2)
      |> String.trim()

    Map.put(parsed_art, :topic, topic)
    |> Map.put(:headline, headline)
    |> Map.put(:subheadline, subheadline)
  end

  # -----------------------------------------------------------------------------------

  defp parse_art_authors(parsed_art, html) do
    authors_html = Floki.find(html, ".a_md_a")

    authors_text = find_text(authors_html)
    authors_urls = Floki.attribute(html, ".a_md_a_n", "href")

    authors =
      Enum.with_index(
        authors_text,
        fn author_text, index ->
          %Author{
            name: author_text,
            url: Enum.at(authors_urls, index)
          }
        end
      )

    Map.put(parsed_art, :authors, authors)
  end

  # -----------------------------------------------------------------------------------

  defp parse_date_and_location(parsed_art, html) do
    date_and_location_html = Floki.find(html, ".a_md_f")
    date_and_location_text = find_text(date_and_location_html)

    location =
      date_and_location_text
      |> Enum.at(0)
      |> String.trim()

    {:ok, date_time, offset} =
      Floki.attribute(date_and_location_html, "time", "datetime")
      |> Enum.at(0)
      |> DateTime.from_iso8601()

    parsed_date_time = DateTime.to_iso8601(date_time, :extended, offset)

    Map.put(parsed_art, :location, location)
    |> Map.put(:date_time, parsed_date_time)
  end

  # -----------------------------------------------------------------------------------

  defp parse_body(parsed_art, html) do
    parsed_body =
      Floki.find(html, ".a_c")
      |> Floki.traverse_and_update(fn
        {"div", _attrs, children} -> children
        {"p", _attrs, children} -> parse_paragraph(children)
        {"a", _attrs, children} -> children
        {_others, _attrs, _children} -> nil
      end)
      |> Enum.join("")
      |> String.split("\n")
      |> Enum.filter(fn paragraph -> paragraph !== "" end)

    Map.put(parsed_art, :body, parsed_body)
  end

  # -----------------------------------------------------------------------------------

  defp parse_paragraph(children) do
    Enum.concat(children, ["\n"])
    |> Enum.join("")
  end

  # ===================================================================================

  def search_articles_test do
    search_articles("rubiales", 1, 10)
    |> parse_search_results()
  end

  def get_article_test do
    get_article(
      # "https://elpais.com/espana/madrid/2023-09-28/un-concejal-del-psoe-de-madrid-expulsado-del-pleno-por-darle-tres-toques-en-la-cara-a-almeida.html"
      # "https://elpais.com/internacional/2023-09-28/detenido-un-hombre-tras-dos-tiroteos-en-roterdam-que-causan-varios-muertos.html"
      "https://elpais.com/espana/catalunya/2023-09-28/erc-y-junts-pactan-condicionar-la-investidura-de-sanchez-a-que-haya-avances-hacia-el-referendum.html"
      # "https://elpais.com/sociedad/2023-09-28/detenido-un-menor-por-agredir-con-arma-blanca-a-varios-docentes-y-alumnos-de-un-instituto-de-jerez-de-la-frontera.html"
    )
    |> parse_article()
  end
end
