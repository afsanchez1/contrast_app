defmodule Core.ElMundoScraperTest do
  alias NewspaperScraper.Core.ElMundoScraper
  use ExUnit.Case, async: true

  # @server_url Application.compile_env(:newspaper_scraper, :el_mundo_base_url) TODO delete this
  @search_url Application.compile_env(:newspaper_scraper, :el_mundo_api_url)
  # ===================================================================================

  describe "get names" do
    test "get_scraper_name/0 works as expected" do
      assert "el-mundo" === ElMundoScraper.get_scraper_name()
    end

    test "get_newspaper_name/0 works as expected" do
      assert "El Mundo" === ElMundoScraper.get_newspaper_name()
    end
  end

  # -----------------------------------------------------------------------------------

  describe "scraper_check/1" do
    test "works for El Mundo URLs" do
      urls = [
        "https://elmundo.es",
        "https://www.elmundo.es/economia.html",
        "https://www.elmundo.es/espana/2023/12/26/658b1445fc6c83a5568b45a7.html",
        "https://ariadna.elmundo.es/buscador/archivo.html?q=test-topic&fd=0&td=0&n=10&w=80&s=0&fecha_busq_avanzada=1"
      ]

      Enum.each(urls, fn url ->
        assert :ok === ElMundoScraper.scraper_check(url)
      end)
    end

    test "returns an error if urls do not match" do
      urls = [
        "https://testurl.es",
        "https://www.elpais.es/economia.html",
        "https://www.abc.es/espana/2023/12/26/658b1445fc6c83a5568b45a7.html",
        "https://this.test.es/buscador/archivo.html"
      ]

      Enum.each(urls, fn url ->
        assert {:error, "invalid url"} === ElMundoScraper.scraper_check(url)
      end)
    end
  end

  # -----------------------------------------------------------------------------------

  describe "get_selectors/1" do
    test "finds all selectors" do
      functions = [
        parse_search_results: [".lista_resultados"],
        check_premium: [".ue-c-article__premium-tag"],
        parse_art_header: [".ue-c-article"],
        parse_art_authors: [".ue-c-article__byline-name"],
        parse_art_date: [".ue-c-article__publishdate"],
        parse_art_body: [".ue-l-article__body"]
      ]

      Enum.map(functions, fn {fun, selectors} ->
        assert selectors === ElMundoScraper.get_selectors(fun)
      end)
    end

    test "returns nil when function not defined" do
      assert nil === ElMundoScraper.get_selectors(:non_existing_fun)
    end
  end

  # -----------------------------------------------------------------------------------

  describe "search_articles/3" do
    test "returns error when resource not found" do
      assert {:error, _e} = ElMundoScraper.search_articles("API_not_found", 0, 4)
    end

    test "returns error when server is not avaliable" do
      assert {:error, _e} = ElMundoScraper.search_articles("API_server_error", 1, 4)
    end

    test "returns ok when request is successful" do
      assert {:ok, _resp} = ElMundoScraper.search_articles("testTopic", 2, 5)
    end
  end

  # -----------------------------------------------------------------------------------
end
