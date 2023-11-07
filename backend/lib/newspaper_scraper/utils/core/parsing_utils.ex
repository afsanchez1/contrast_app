defmodule NewspaperScraper.Utils.Core.ParsingUtils do
  def find_element(_html, []) do
    {:error, :not_found}
  end

  def find_element(html, [selector | t]) do
    case Floki.find(html, selector) do
      [] -> find_element(html, t)
      found -> found
    end
  end

  def transform_text_children(children) do
    children
    |> Floki.text()
    |> String.trim()
  end

  def transform_attributes(attrs), do: Map.new(attrs)
end
