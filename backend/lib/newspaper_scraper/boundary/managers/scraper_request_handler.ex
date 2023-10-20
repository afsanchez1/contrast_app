defmodule NewspaperScraper.Boundary.Managers.ScraperRequestHandler do
  alias NewspaperScraper.Utils.Managers.StageUtils
  alias NewspaperScraper.Boundary.Managers.ScraperEventManager
  use GenStage

  require Logger

  def start_link(opts \\ []) do
    GenStage.start_link(__MODULE__, :ok, opts)
  end

  def handle_requests({:search_articles, req: req, client: client}) do
    topic = req.topic
    page = req.page
    limit = req.limit
    scrapers = StageUtils.get_scrapers()

    res =
      Enum.map(
        scrapers,
        fn scraper ->
          with {:ok, raw_art_summs} <- scraper.search_articles(topic, page, limit),
               do: {:ok, scraper: scraper, raw_art_summs: raw_art_summs},
               else: (error -> error)
        end
      )

    {:parse_search_results, res: res, client: client}
  end

  def handle_requests({:get_article, req: req, client: client}) do
    url = req.url
    scrapers = StageUtils.get_scrapers()

    res =
      with {:ok, scraper} <- find_scraper(url, scrapers),
           {:ok, {raw_article, url}} <- scraper.get_article(url),
           do: {:ok, scraper: scraper, raw_art: raw_article, url: url},
           else: (error -> error)

    {:parse_article, res: res, client: client}
  end

  def find_scraper(url, scrapers) do
    found = Enum.find(scrapers, fn scraper -> scraper.scraper_check(url) === :ok end)

    case found do
      nil -> {:error, "invalid url"}
      scraper -> {:ok, scraper}
    end
  end

  # GenStage Callbacks

  @impl true
  def init(:ok) do
    Logger.info("ScraperRequestHandler is ready")
    {:producer_consumer, :ok, subscribe_to: [{ScraperEventManager, max_demand: 10, min_demand: 5}]}
  end

  @impl true
  def handle_events(events, _from, state) do
    next_events = Enum.map(events, &handle_requests/1)

    {:noreply, next_events, state}
  end
end
