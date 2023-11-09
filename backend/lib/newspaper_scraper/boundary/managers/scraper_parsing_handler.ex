defmodule NewspaperScraper.Boundary.Managers.ScraperParsingHandler do
  alias NewspaperScraper.Utils.Managers.StageUtils
  require Logger

  def start_link(event) do
    Task.start_link(fn ->
      event
      |> parse_responses()
      |> handle_reply()
    end)
  end

  def handle_reply({_res_type, res}) do
    client = res[:client]
    parsed_content = res[:parsed]
    GenServer.reply(client, parsed_content)
  end

  def parse_responses({:parse_search_results, res: res, client: client}) do
    parsed_art_summs = Enum.map(res, &parse_search_results/1)

    {:parsed_art_summs, parsed: parsed_art_summs, client: client}
  end

  def parse_responses({:parse_article, res: res, client: client}) do
    parsed_art =
      case res do
        {:ok, scraper: scraper, raw_art: raw_article, url: url} ->
          with {:ok, parsed_art} <- scraper.parse_article(raw_article, url),
               do: {:ok, parsed_art},
               else: (error -> StageUtils.build_error(scraper, error))

        {:error, e} ->
          {:error, e}
      end

    {:parsed_art, parsed: parsed_art, client: client}
  end

  defp parse_search_results(res) do
    with {:ok, scraper: scraper, raw_art_summs: raw_art_summs} <- res,
         {:ok, parsed_art} <- scraper.parse_search_results(raw_art_summs),
         do: %{scraper: scraper.get_scraper_name(), results: parsed_art},
         else: (error -> error)
  end
end
