defmodule NewspaperScraper.Boundary.ScraperManager do
  require Logger
  use GenServer
  alias NewspaperScraper.Boundary.Managers.ScraperEventManager
  alias NewspaperScraper.Boundary.Managers.ScraperRequestHandler
  alias NewspaperScraper.Boundary.Managers.ScraperParsingHandlerSupervisor

  @timeout 10_000
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, :ok, options)
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

  # GenServer Callbacks

  @impl true
  def init(:ok) do
    Logger.info("ScraperManager is ready")

    children = [
      {ScraperEventManager, []},
      {ScraperRequestHandler, []},
      {ScraperParsingHandlerSupervisor, []}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
    {:ok, :ok}
  end

  @impl true
  def handle_call({:search_articles, req}, from, state) do
    ScraperEventManager.sync_notify({:search_articles, req: req, client: from})

    {:noreply, state}
  end

  @impl true
  def handle_call({:get_article, req}, from, state) do
    ScraperEventManager.sync_notify({:get_article, req: req, client: from})

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
