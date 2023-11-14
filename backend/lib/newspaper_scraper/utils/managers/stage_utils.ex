defmodule NewspaperScraper.Utils.Managers.StageUtils do
  @moduledoc """
  Utilities for scraper stages
  """

  @doc """
  Transforms errors format
  """
  @spec build_error(module(), {:error, any()}) :: {:error, map()}
  def build_error(scraper, {:error, e}) do
    scraper_name = String.to_atom(scraper.get_scraper_name)
    {:error, %{scraper_name => e}}
  end
end
