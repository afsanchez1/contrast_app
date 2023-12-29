defmodule ElMundoTest do
  alias NewspaperScraper.Utils.Core.ParsingUtils
  alias NewspaperScraper.Core.ElMundoScraper

  def test do
    {:ok, html} =
      [
        "feminismo",
        "rubiales",
        "cataluña",
        "política España",
        "Pedro Sánchez",
        "extrema derecha",
        "economía",
        "milei",
        "nuevas tecnologías",
        "educación social",
        "biotecnología",
        "robotización"
      ]
      |> Enum.random()
      |> ElMundoScraper.search_articles(0, 5)
      |> Tuple.to_list()
      |> Enum.at(1)
      |> ElMundoScraper.parse_search_results()
      |> Enum.random()
      |> Map.get(:url)
      |> dbg()
      |> ElMundoScraper.get_article()
      |> Tuple.to_list()
      |> Enum.at(1)
      |> Tuple.to_list()
      |> Enum.at(0)
      |> Floki.parse_document()

    parse_all(html)
  end

  def test_url(url) do
    {:ok, html} =
      ElMundoScraper.get_article(url)
      |> Tuple.to_list()
      |> Enum.at(1)
      |> Tuple.to_list()
      |> Enum.at(0)
      |> Floki.parse_document()

    parse_all(html)
  end

  defp parse_all(html) do
    case ParsingUtils.check_premium(html, ElMundoScraper) do
      true ->
        {:error, "forbidden content"}

      false ->
        %{}
        |> ParsingUtils.parse(:parse_art_header, html, ElMundoScraper)
        |> ParsingUtils.parse(:parse_art_authors, html, ElMundoScraper)
    end
  end
end

ElMundoTest.test()
