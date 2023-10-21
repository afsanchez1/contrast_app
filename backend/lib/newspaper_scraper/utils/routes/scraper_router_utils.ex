defmodule NewspaperScraper.Utils.Routes.ScraperRouterUtils do
  def transform_search_articles_query_params(query) do
    for {key, value} <- query, into: %{} do
      cond do
        key === :page or key === :limit ->
          case Integer.parse(value) do
            {num, _rem} -> {key, num}
            _ -> {key, value}
          end

        true ->
          {key, value}
      end
    end
  end
end
