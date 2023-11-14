defmodule NewspaperScraper.Boundary.Managers.ScraperRequestHandler do
  @moduledoc """
  This module contains the logic to handle requests for all the scrapers
  """
  alias NewspaperScraper.Boundary.Managers.ScraperEventManager
  alias NewspaperScraper.Utils.Managers.StageUtils

  use GenStage

  require Logger

  @scrapers Application.compile_env(:newspaper_scraper, :scrapers)
  @max_demand 10
  @min_demand 5

  @doc """
  Starts a link with a ScraperRequestHandler process
  """
  @spec start_link(opts :: list()) :: {:ok, pid()} | {:error, reason :: any()}
  def start_link(opts) do
    GenStage.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Handles both types of possible requests to the scrapers
  """
  @spec handle_requests(
          {:search_articles, [req: map(), client: pid()]}
          | {:get_article, [req: map(), client: pid()]}
        ) ::
          {:parse_search_results, [res: {:ok, keyword()}, client: pid()]}
          | {:parse_article, [res: {:ok, keyword()} | {:error, any()}, client: pid()]}
  def handle_requests({:search_articles, req: req, client: client}) do
    topic = req.topic
    page = req.page
    limit = req.limit
    scrapers = @scrapers

    res =
      Enum.map(
        scrapers,
        fn scraper ->
          case scraper.search_articles(topic, page, limit) do
            {:ok, raw_art_summs} -> {:ok, scraper: scraper, raw_art_summs: raw_art_summs}
            error -> StageUtils.build_error(scraper, error)
          end
        end
      )

    {:parse_search_results, res: res, client: client}
  end

  def handle_requests({:get_article, req: req, client: client}) do
    url = req.url
    scrapers = @scrapers

    res =
      with {:ok, scraper} <- find_scraper(url, scrapers),
           {:ok, {raw_article, url}} <- scraper.get_article(url),
           do: {:ok, scraper: scraper, raw_art: raw_article, url: url},
           else: (error -> error)

    {:parse_article, res: res, client: client}
  end

  @doc """
  Finds the correct scraper for the request
  """
  @spec find_scraper(url :: String.t(), scrapers :: list(module())) ::
          {:ok, scraper :: module()} | {:error, String.t()}
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

    {:producer_consumer, :ok,
     subscribe_to: [{ScraperEventManager, max_demand: @max_demand, min_demand: @min_demand}]}
  end

  @impl true
  def handle_events(events, _from, state) do
    tasks =
      Enum.map(
        events,
        fn event ->
          Task.async(fn -> handle_requests(event) end)
        end
      )

    next_events = Task.await_many(tasks)

    {:noreply, next_events, state}
  end
end
