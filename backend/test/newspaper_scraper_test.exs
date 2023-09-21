defmodule NewspaperScraperTest do
  use ExUnit.Case
  doctest NewspaperScraper

  test "greets the world" do
    assert NewspaperScraper.hello() == :world
  end
end
