defmodule NewspaperScraper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias NewspaperScraper.Boundary.Routes.ScraperRouter
  alias NewspaperScraper.Boundary.ScraperManager

  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    Logger.info("Starting Application...")

    children = [
      {Plug.Cowboy, scheme: :http, plug: ScraperRouter, options: [port: 8080]},
      {ScraperManager, [name: ScraperManager]}
    ]

    opts = [strategy: :one_for_one, name: NewspaperScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
