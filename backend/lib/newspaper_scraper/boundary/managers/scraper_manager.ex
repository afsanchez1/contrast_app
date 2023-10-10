defmodule NewspaperScraper.Boundary.ScraperManager do
  use GenServer

  @impl true
  def init(scrapers) when is_list(scrapers) do
    {:ok, scrapers}
  end

  @impl true
  def init(_scrapers), do: {:error, "Scrapers must be a list"}

  @impl true
  def handle_call({:search_articles, %{topic: topic, page: page, limit: limit}}, _from, scrapers) do
    res = aux_search_articles(topic, page, limit, scrapers)

    {:reply, {:ok, res}, scrapers}
  end

  @impl true
  def handle_call({:get_article, %{url: url}}, _from, scrapers) do
    res = aux_get_article(url, scrapers)

    {:reply, res, scrapers}
  end

  defp aux_search_articles(topic, page, limit, scrapers) do
    Enum.flat_map(
        scrapers,
        fn scraper ->
          with {:ok, raw_art_summs} <- scraper.search_articles(topic, page, limit),
               {:ok, parsed_art_summs} <- scraper.parse_search_results(raw_art_summs),
               do: parsed_art_summs,
               else: (error -> error)
        end
      )
  end

  defp aux_get_article(url, scrapers) do
    Enum.map(
        scrapers,
        fn scraper ->
          with {:ok, {raw_article, url}} <- scraper.get_article(url),
               {:ok, parsed_art} <- scraper.parse_article(raw_article, url),
               do: {:ok, parsed_art},
               else: (error -> error)
        end
      )
  end

  def search_articles(manager \\ __MODULE__, topic, page, limit) do
    GenServer.call(manager, {:search_articles, [topic: topic, page: page, limit: limit]})
  end

  def get_article(manager \\ __MODULE__, url) do
    GenServer.call(manager, {:get_articles, url})
  end
end
