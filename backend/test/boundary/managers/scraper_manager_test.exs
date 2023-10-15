defmodule Boundary.Managers.ScraperManagerTest do
  alias NewspaperScraper.Core.ElPaisScraper
  alias NewspaperScraper.Boundary.ScraperManager
  use ExUnit.Case, async: true

  @server_name :test_manager
  @scrapers [
    ElPaisScraper
  ]

  defp create_manager do
    {:ok, pid} = GenServer.start(ScraperManager, @scrapers, name: @server_name)
    {:ok, [pid: pid]}
  end

  defp kill_manager, do: fn -> send(@server_name, :terminate) end

  setup_all do
    on_exit(:kill_manager, kill_manager())
    create_manager()
  end

  describe "init/1" do
    test "init should fail when type is not correct" do
      manager_name = :init_test

      assert {:error, "scrapers must be a list"} =
               GenServer.start(ScraperManager, %{}, name: manager_name)

      assert {:error, "scrapers must be a list"} =
               GenServer.start(ScraperManager, "test", name: manager_name)

      assert {:error, "scrapers must be a list"} =
               GenServer.start(ScraperManager, 24, name: manager_name)
    end
  end

  describe "start_link/1" do
    test "start_link works" do
      manager_name = :link_test

      # Start the link
      assert {:ok, pid} = ScraperManager.start_link(name: manager_name)
      assert Process.alive?(pid)
      assert pid === Process.whereis(manager_name)

      # Try to kill it
      send(manager_name, :terminate)

      assert Process.alive?(pid)

      # Unlink and try to kill it again
      Process.unlink(pid)
      send(manager_name, :terminate)

      # Wait for it to die
      Process.sleep(500)

      assert not Process.alive?(pid)
    end
  end

  describe "search_articles/4" do
    test "search articles works" do
      assert {:ok, _res} =
               ScraperManager.search_articles(@server_name, "israel y palestina", 1, 2)
    end
  end

  describe "get_article/2" do
    test "get article works" do
      assert {:ok, _res} =
               ScraperManager.get_article(
                 @server_name,
                 "https://elpais.com/opinion/2023-10-11/aterrizaje-suave-en-la-economia-global.html?rel=buscador_noticias"
               )
    end

    test "get article should fail with premium article" do
      assert {:error, _err} =
               ScraperManager.get_article(
                 @server_name,
                 "https://elpais.com/internacional/2023-10-10/la-ue-advierte-a-musk-de-que-la-red-social-x-se-usa-para-desinformar-tras-los-ataques-de-hamas-y-reclama-medidas.html"
               )
    end

    test "get article should fail with bad url" do
      assert {:error, _err} =
               ScraperManager.get_article(
                 @server_name,
                 "https://udc.com/internacional/2023-10-10/la-ue-advierte-a-musk-de-que-la-red-social-x-se-usa-para-desinformar-tras-los-ataques-de-hamas-y-reclama-medidas.html"
               )
    end
  end
end
