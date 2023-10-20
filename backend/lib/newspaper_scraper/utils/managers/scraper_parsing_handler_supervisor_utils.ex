defmodule NewspaperScraper.Utils.Managers.ScraperParsingHandlerSupervisorUtils do
  def build_subscriptions(subscription_names, max_demand, min_demand) do
    Enum.map(
      subscription_names,
      fn subscription_name ->
        {subscription_name, max_demand: max_demand, min_demand: min_demand}
      end
    )
  end
end
