defmodule NewspaperScraper.Utils.Core.ParsingUtils do
  alias NewspaperScraper.Core.Scraper
  @moduledoc """
  Parsing utilities for the scrapers
  """

  @doc """
  Tries to find an element using a selector
  """
  @spec find_element(Scraper.html_tree(), list()) :: list() | {:error, :not_found}
  def find_element(_html, []) do
    {:error, :not_found}
  end

  def find_element(html, [selector | t]) do
    case Floki.find(html, selector) do
      [] -> find_element(html, t)
      found -> found
    end
  end

  @doc """
  Transforms HTML text children
  """
  @spec transform_text_children(list()) :: String.t()
  def transform_text_children(children) do
    children
    |> Floki.text()
    |> String.trim()
  end

  @doc """
  Transforms a list of a HTML attributes into a map
  """
  @spec transform_attributes(list()) :: map()
  def transform_attributes(attrs), do: Map.new(attrs)
end
