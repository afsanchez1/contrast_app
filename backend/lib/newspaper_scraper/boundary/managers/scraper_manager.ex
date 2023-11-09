defmodule NewspaperScraper.Boundary.ScraperManager do
  alias NewspaperScraper.Boundary.Managers.ScraperEventManager
  alias NewspaperScraper.Boundary.Managers.ScraperRequestHandler
  alias NewspaperScraper.Boundary.Managers.ScraperParsingHandlerSupervisor
  use GenServer

  require Logger

  @timeout 20_000

  # ===================================================================================

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options[:args], options)
  end

  # ---------------------------------------------------------------------------------

  def search_articles(manager \\ __MODULE__, topic, page, limit) do
    req = %{
      topic: topic,
      page: page,
      limit: limit
    }

    GenServer.call(manager, {:search_articles, req}, @timeout)
  end

  # ---------------------------------------------------------------------------------

  def get_article(manager \\ __MODULE__, url) do
    req = %{
      url: url
    }

    GenServer.call(manager, {:get_article, req}, @timeout)
  end

  # ===================================================================================

  defp build_children(num_req_handlers) do
    {req_handlers, names} = build_req_handlers(num_req_handlers)

    [{ScraperEventManager, []}] ++
      req_handlers ++
      [{ScraperParsingHandlerSupervisor, subscription_names: names}]
  end

  # ---------------------------------------------------------------------------------

  defp build_req_handlers(num_req_handlers) do
    names =
      for num <- 1..num_req_handlers do
        (to_string(ScraperRequestHandler) <> "_" <> to_string(num))
        |> String.to_atom()
      end

    children =
      Enum.map(
        names,
        fn name ->
          Supervisor.child_spec({ScraperRequestHandler, name: name}, id: name)
        end
      )

    {children, names}
  end

  # ===================================================================================
  # GenServer Callbacks
  # ===================================================================================

  @impl true
  def init(args) do
    Logger.info("ScraperManager is ready")

    num_req_handlers = args[:num_req_handlers]

    try do
      children = build_children(num_req_handlers)
      sup = Supervisor.start_link(children, strategy: :rest_for_one)

      case sup do
        {:ok, pid} -> {:ok, pid}
        {:error, e} -> {:stop, e}
      end
    rescue
      e -> {:stop, e.message}
    end
  end

  # ---------------------------------------------------------------------------------

  @impl true
  def handle_call({:search_articles, req}, from, state) do
    ScraperEventManager.push_event({:search_articles, req: req, client: from})

    {:noreply, state}
  end

  # ---------------------------------------------------------------------------------

  @impl true
  def handle_call({:get_article, req}, from, state) do
    ScraperEventManager.push_event({:get_article, req: req, client: from})

    {:noreply, state}
  end

  # ---------------------------------------------------------------------------------

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  # ---------------------------------------------------------------------------------

  @impl true
  def terminate(reason, state) do
    Logger.alert("ScraperManager terminated", reason: reason, state: state)
  end
end
