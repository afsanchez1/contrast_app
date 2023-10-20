defmodule NewspaperScraper.Utils.Managers.StageUtils do
  alias NewspaperScraper.Core.ElPaisScraper

  def dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  def dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, {from, event}}, queue} ->
        GenStage.reply(from, :ok)
        dispatch_events(queue, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end

  def get_scrapers() do
    [
      ElPaisScraper
    ]
  end
end
