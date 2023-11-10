defmodule NewspaperScraper.Boundary.Managers.ScraperEventManager do
  require Logger
  use GenStage

  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def push_event(event, timeout \\ 5000) do
    GenStage.call(__MODULE__, {:push, event}, timeout)
  end

  def dispatch_events(queue, demand, events) do
    with d when d > 0 <- demand,
         {item, queue} = :queue.out(queue),
         {:value, {from, event}} <- item do
      GenStage.reply(from, :ok)
      dispatch_events(queue, demand - 1, [event | events])
    else
      _ -> {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end

  # GenStage Callbacks

  @impl true
  def init(:ok) do
    Logger.info("ScraperEventManager is ready")
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  @impl true
  def handle_call({:push, event}, from, {queue, pending_demand}) do
    dispatch_events(:queue.in({from, event}, queue), pending_demand, [])
  end

  @impl true
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end
end
