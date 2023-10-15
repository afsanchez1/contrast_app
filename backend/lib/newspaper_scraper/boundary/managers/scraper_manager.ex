defmodule NewspaperScraper.Boundary.ScraperManager do
  require Logger
  use GenServer
  alias NewspaperScraper.Core.ElPaisScraper

  @timeout 10_000
  @scrapers [
    ElPaisScraper
  ]

  @impl true
  def init(scrapers) when is_list(scrapers) do
    Logger.info("ScraperManager is ready")
    {:ok, scrapers}
  end

  @impl true
  def init(_scrapers), do: {:error, "scrapers must be a list"}

  @impl true
  def handle_call({:search_articles, %{topic: topic, page: page, limit: limit}}, _from, scrapers) do
    res =
      Enum.map(
        scrapers,
        fn scraper ->
          with {:ok, raw_art_summs} <- scraper.search_articles(topic, page, limit),
               {:ok, parsed_art_summs} <- scraper.parse_search_results(raw_art_summs),
               do: {scraper, parsed_art_summs},
               else: (error -> error)
        end
      )

    {:reply, {:ok, res}, scrapers}
  end

  @impl true
  def handle_call({:get_article, %{url: url}}, _from, scrapers) do
    res =
      with {:ok, scraper} <- find_scraper(url, scrapers),
           {:ok, {raw_article, url}} <- scraper.get_article(url),
           {:ok, parsed_art} <- scraper.parse_article(raw_article, url),
           do: {:ok, parsed_art},
           else: (error -> error)

    {:reply, res, scrapers}
  end

  @impl true
  def handle_info(:terminate, scrapers) do
    {:stop, :normal, scrapers}
  end

  @impl true
  def terminate(reason, state) do
    Logger.alert("ScraperManager terminated", reason: reason, state: state)
  end

  defp find_scraper(url, scrapers) do
    found = Enum.find(scrapers, fn scraper -> scraper.scraper_check(url) === :ok end)

    case found do
      nil -> {:error, "invalid url"}
      scraper -> {:ok, scraper}
    end
  end

  def search_articles(manager \\ __MODULE__, topic, page, limit) do
    GenServer.call(
      manager,
      {:search_articles, %{topic: topic, page: page, limit: limit}},
      @timeout
    )
  end

  def get_article(manager \\ __MODULE__, url) do
    GenServer.call(manager, {:get_article, %{url: url}}, @timeout)
  end

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, @scrapers, options)
  end
end
