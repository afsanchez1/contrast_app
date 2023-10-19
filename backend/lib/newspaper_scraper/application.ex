defmodule NewspaperScraper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias NewspaperScraper.Boundary.ScraperManager
  alias NewspaperScraper.Boundary.Managers.ScraperEventManager
  alias NewspaperScraper.Boundary.Managers.ScraperRequestHandler
  alias NewspaperScraper.Boundary.Managers.ScraperParsingHandler
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    Logger.info("Starting Application...")

    children = [
      {ScraperManager, [name: ScraperManager]},
      {ScraperEventManager, []},
      {ScraperRequestHandler, []},
      {ScraperParsingHandler, []}
    ]

    opts = [strategy: :one_for_one, name: NewspaperScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
