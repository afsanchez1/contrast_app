defmodule Boundary.Managers.ScraperManagerTest do
  alias NewspaperScraper.Core.ElPaisScraper
  alias NewspaperScraper.Boundary.ScraperManager
  use ExUnit.Case

  @scrapers [
    ElPaisScraper
  ]

  defp create_manager do
    {:ok, pid} = GenServer.start(ScraperManager, @scrapers, name: ScraperManager)
    {:ok, [pid: pid]}
  end

  setup_all do
    on_exit(:kill_manager, fn -> send(ScraperManager, :terminate) end)
    create_manager()
  end

  describe "search_articles/4" do
    test "search articles works" do
      assert {:ok, _res} =
               ScraperManager.search_articles("israel y palestina", 1, 2)
    end
  end

  describe "get_article/2" do
    test "get article works" do
      assert {:ok, _res} =
               ScraperManager.get_article(
                 "https://elpais.com/opinion/2023-10-11/aterrizaje-suave-en-la-economia-global.html?rel=buscador_noticias"
               )
    end

    test "get article should fail with premium article" do
      assert {:error, _err} =
               ScraperManager.get_article(
                 "https://elpais.com/internacional/2023-10-10/la-ue-advierte-a-musk-de-que-la-red-social-x-se-usa-para-desinformar-tras-los-ataques-de-hamas-y-reclama-medidas.html"
               )
    end

    test "get article should fail with bad url" do
      assert {:error, _err} =
        ScraperManager.get_article(
          "https://udc.com/internacional/2023-10-10/la-ue-advierte-a-musk-de-que-la-red-social-x-se-usa-para-desinformar-tras-los-ataques-de-hamas-y-reclama-medidas.html"
        )
    end
  end
end
