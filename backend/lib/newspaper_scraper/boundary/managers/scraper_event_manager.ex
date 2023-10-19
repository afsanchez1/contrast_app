defmodule NewspaperScraper.Boundary.Managers.ScraperEventManager do
  alias NewspaperScraper.Utils.Managers.StageUtils
  use GenStage

  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def sync_notify(event, timeout \\ 5000) do
    GenStage.call(__MODULE__, {:notify, event}, timeout)
  end

  # GenStage Callbacks

  @impl true
  def init(:ok) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.DemandDispatcher}
  end

  @impl true
  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    StageUtils.dispatch_events(:queue.in({from, event}, queue), pending_demand, [])
  end

  @impl true
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    StageUtils.dispatch_events(queue, incoming_demand + pending_demand, [])
  end
end
