defmodule NewspaperScraper.Boundary.Managers.ScraperParsingHandler do
  alias NewspaperScraper.Boundary.Managers.ScraperRequestHandler
  use GenStage

  def start_link(_args) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def parse_responses({:parse_search_results, res: res, client: client}) do
    parsed_art_summs = Enum.map(res, &parse_search_results/1)

    {:parsed_art_summs, parsed: parsed_art_summs, client: client}
  end

  def parse_responses({:parse_article, res: res, client: client}) do
    parsed_art =
      with {:ok, scraper: scraper, raw_art: raw_article, url: url} <- res,
           {:ok, parsed_art} <- scraper.parse_article(raw_article, url),
           do: {:ok, parsed_art},
           else: (error -> error)

    {:parsed_art, parsed: parsed_art, client: client}
  end

  defp parse_search_results(res) do
    with {:ok, scraper: scraper, raw_art_summs: raw_art_summs} <- res,
         {:ok, parsed_art} <- scraper.parse_search_results(raw_art_summs),
         do: {:ok, {scraper, parsed_art}},
         else: (error -> error)
  end

  # GenStage Callbacks

  @impl true
  def init(:ok) do
    {:consumer, :ok, subscribe_to: [ScraperRequestHandler]}
  end

  @impl true
  def handle_events(events, _from, state) do
    events
    |> Enum.map(&parse_responses/1)
    |> Enum.map(fn {res_type, res} ->
      client = res[:client]
      parsed_content = res[:parsed]
      GenServer.reply(client, {res_type, parsed_content})
    end)

    {:noreply, [], state}
  end
end
