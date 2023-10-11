defmodule NewspaperScraper.Boundary.ScraperValidator do
  import NewspaperScraper.Boundary.Validator

  @max_limit 5
  @base_urls [
    "elpais.com"
  ]

  def search_articles_errors(fields) when is_map(fields) do
    []
    |> mandatory(fields, :topic, &validate_topic/1)
    |> mandatory(fields, :page, &validate_page/1)
    |> mandatory(fields, :limit, &validate_limit/1)
    |> has_errors()
  end

  def get_article_errors(fields) when is_map(fields) do
    []
    |> mandatory(fields, :url, &validate_url/1)
    |> has_errors()
  end

  defp validate_topic(topic) when is_binary(topic) do
    check(not String.match?(topic, ~r{^(?=\s*$)}), {:error, "is mandatory"})
  end

  defp validate_topic(_topic), do: {:error, "must be a binary"}

  defp validate_page(page) when is_integer(page), do: :ok

  defp validate_page(_page), do: {:error, "must be an integer"}

  defp validate_limit(limit) when is_integer(limit) do
    check(limit <= @max_limit, {:error, "max. limit exceeded"})
  end

  defp validate_limit(_limit), do: {:error, "must be a binary"}

  defp validate_url(url) when is_binary(url) do
    Enum.map(
      @base_urls,
      fn base_url ->
        String.contains?(url, base_url)
      end
    )
    |> Enum.reduce(fn elem, acc -> acc or elem end)
    |> check({:error, "must be a valid newspaper"})
  end

  defp validate_url(_url), do: {:error, "must be a binary"}
end
