defmodule NewspaperScraper.Boundary.ScraperManager do
  alias NewspaperScraper.Utils.Managers.ScraperManagerUtils
  alias NewspaperScraper.Boundary.Managers.ScraperEventManager
  use GenServer

  require Logger

  @timeout 20_000

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options[:args], options)
  end

  def search_articles(manager \\ __MODULE__, topic, page, limit) do
    req = %{
      topic: topic,
      page: page,
      limit: limit
    }

    GenServer.call(manager, {:search_articles, req}, @timeout)
  end

  def get_article(manager \\ __MODULE__, url) do
    req = %{
      url: url
    }

    GenServer.call(manager, {:get_article, req}, @timeout)
  end

  # GenServer Callbacks

  @impl true
  def init(args) do
    Logger.info("ScraperManager is ready")

    req_handlers = args[:req_handlers]

    children = ScraperManagerUtils.build_children(req_handlers)

    Supervisor.start_link(children, strategy: :rest_for_one)

    {:ok, :ok}
  end

  @impl true
  def handle_call({:search_articles, req}, from, state) do
    ScraperEventManager.push_event({:search_articles, req: req, client: from})

    {:noreply, state}
  end

  @impl true
  def handle_call({:get_article, req}, from, state) do
    ScraperEventManager.push_event({:get_article, req: req, client: from})

    {:noreply, state}
  end

  @impl true
  def handle_info(:terminate, scrapers) do
    {:stop, :normal, scrapers}
  end

  @impl true
  def terminate(reason, state) do
    Logger.alert("ScraperManager terminated", reason: reason, state: state)
  end
end
