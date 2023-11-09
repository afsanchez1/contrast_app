defmodule NewspaperScraper.Utils.Managers.StageUtils do
  def build_error(scraper, {:error, e}) do
    scraper_name = String.to_atom(scraper.get_scraper_name)
    {:error, %{scraper_name => e}}
  end
end
