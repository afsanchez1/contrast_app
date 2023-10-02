defmodule NewspaperScraper.Core.ElPaisScraper do
  @behaviour Scraper
  use Tesla
  alias NewspaperScraper.Model.ArticleSummary, as: ArticleSummary
  alias NewspaperScraper.Model.Article, as: Article

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

    Tesla.get(@client, url)
  end

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_search_results({:ok, %Tesla.Env{body: %{"articles" => articles}}}) do
    Enum.map(
      articles,
      fn article ->
        date_time =
          article["updatedTs"]
          |> DateTime.from_unix(:second)
          |> Tuple.to_list()
          |> Enum.at(1)
          |> DateTime.to_iso8601()

        %ArticleSummary{
          newspaper: "El País",
          authors: article["authors"],
          title: article["title"],
          excerpt: article["excerpt"],
          date_time: date_time,
          url: article["url"]
        }
      end
    )
    # TODO eliminar pretty
    |> Jason.encode(pretty: true)
  end

  # ===================================================================================

  @impl Scraper
  def get_article(url), do: Tesla.get(@client, url)

  # -----------------------------------------------------------------------------------

  @impl Scraper
  def parse_article({:ok, %Tesla.Env{body: html_doc, url: url}}) do
    {:ok, html} = Floki.parse_document(html_doc)

    temp_art =
      parse_header(%{}, html)
      |> parse_authors(html)
      |> parse_date_and_location(html)
      |> parse_body(html)

    %Article{
      newspaper: "El País",
      topic: temp_art.topic,
      headline: temp_art.headline,
      subheadline: temp_art.subheadline,
      authors: temp_art.authors,
      date_time: temp_art.date_time,
      location: temp_art.location,
      body: temp_art.body,
      url: url
    }
    # TODO delete pretty
    |> Jason.encode(pretty: true)
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
      %{
        name: Enum.at(header_text, 0),
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

  defp parse_authors(parsed_art, html) do
    authors_html = Floki.find(html, ".a_md_a")

    authors_text = find_text(authors_html)
    authors_urls = Floki.attribute(html, ".a_md_a_n", "href")

    authors =
      Enum.with_index(
        authors_text,
        fn author_text, index ->
          %{
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

    # TODO already an ISO 8601 date (check should be implemented)
    {:ok, date_time, offset} =
      Floki.attribute(date_and_location_html, "time", "datetime")
      |> Enum.at(0)
      |> DateTime.from_iso8601()

    parsed_date_time = DateTime.to_iso8601(date_time, :extended, offset)

    Map.put(parsed_art, :location, location)
    |> Map.put(:date_time, parsed_date_time)
  end

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

    Map.put(parsed_art, :body, parsed_body)
  end

  defp parse_paragraph(children) do
    Enum.concat(children, ["\n"])
    |> Enum.join("")
  end

  # ===================================================================================

  def search_articles_test do
    search_articles("ucrania", 1, 2)
    |> parse_search_results()
    |> Tuple.to_list()
    |> Enum.at(1)
    |> IO.puts()
  end

  def get_article_test do
    get_article(
      # "https://elpais.com/espana/madrid/2023-09-28/un-concejal-del-psoe-de-madrid-expulsado-del-pleno-por-darle-tres-toques-en-la-cara-a-almeida.html"
      "https://elpais.com/internacional/2023-09-28/detenido-un-hombre-tras-dos-tiroteos-en-roterdam-que-causan-varios-muertos.html"
    )
    |> parse_article()
    |> Tuple.to_list()
    |> Enum.at(1)
    |> IO.puts()
  end
end
