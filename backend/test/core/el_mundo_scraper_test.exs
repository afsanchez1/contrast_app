defmodule Core.ElMundoScraperTest do
  alias NewspaperScraper.Core.ElMundoScraper
  use ExUnit.Case, async: true

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

  # TODO implement function and tests
  # describe "get_selectors/1" do
  #  test "finds all selectors" do
  #    assert :ok === :error
  #  end
  # end

  # -----------------------------------------------------------------------------------
end
