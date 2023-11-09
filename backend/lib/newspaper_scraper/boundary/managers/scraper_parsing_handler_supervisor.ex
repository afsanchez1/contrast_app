defmodule NewspaperScraper.Boundary.Managers.ScraperParsingHandlerSupervisor do
  alias NewspaperScraper.Boundary.Managers.ScraperParsingHandler
  use ConsumerSupervisor

  require Logger

  @max_demand 10
  @min_demand 5

  def start_link(arg) do
    ConsumerSupervisor.start_link(__MODULE__, arg)
  end

  def init(arg) do
    Logger.info("ScraperParsingHandlerSupervisor is ready")

    subscription_names = arg[:subscription_names]

    subscriptions =
      build_subscriptions(
        subscription_names,
        @max_demand,
        @min_demand
      )

    children = [
      %{
        id: ScraperParsingHandler,
        start: {ScraperParsingHandler, :start_link, []},
        restart: :transient
      }
    ]

    opts = [
      strategy: :one_for_one,
      subscribe_to: subscriptions
    ]

    ConsumerSupervisor.init(children, opts)
  end

  defp build_subscriptions(subscription_names, max_demand, min_demand) do
    Enum.map(
      subscription_names,
      fn subscription_name ->
        {subscription_name, max_demand: max_demand, min_demand: min_demand}
      end
    )
  end
end
