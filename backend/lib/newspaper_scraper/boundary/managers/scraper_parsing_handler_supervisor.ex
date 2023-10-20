defmodule NewspaperScraper.Boundary.Managers.ScraperParsingHandlerSupervisor do
  alias NewspaperScraper.Boundary.Managers.ScraperParsingHandler
  alias NewspaperScraper.Boundary.Managers.ScraperRequestHandler
  use ConsumerSupervisor

  def start_link(arg) do
    ConsumerSupervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    children = [
      %{
        id: ScraperParsingHandler,
        start: {ScraperParsingHandler, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{ScraperRequestHandler, max_demand: 10, min_demand: 5}]
    ]

    ConsumerSupervisor.init(children, opts)
  end
end
