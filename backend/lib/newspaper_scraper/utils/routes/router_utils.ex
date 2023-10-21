defmodule NewspaperScraper.Utils.Routes.RouterUtils do
  def transform_error({:error, value}) when is_list(value) do
    transformed_value = for member <- value, do: Map.new([member])
    Map.new([{:error, transformed_value}])
  end

  def transform_error(error), do: Map.new([error])

  def transform_query_params(params) when params === %{}, do: %{}

  def transform_query_params(params) do
    for {key, val} <- params, into: %{} do
      {String.to_atom(key), val}
    end
  end
end