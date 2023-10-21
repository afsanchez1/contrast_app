defmodule NewspaperScraper.Utils.Routes.ScraperRouterUtilsTest do
  alias NewspaperScraper.Utils.Routes.ScraperRouterUtils
  use ExUnit.Case, async: true

  describe "transform_search_articles_query_params/1" do
    test "transforms values correctly" do
      empty_query = %{}

      full_query = %{
        topic: "testTopic",
        page: "1",
        limit: "2"
      }

      partial_query = %{
        page: "20",
        limit: "300"
      }

      float_query = %{
        page: "200.456"
      }

      exptd_empty_query = %{}

      exptd_full_query = %{
        topic: "testTopic",
        page: 1,
        limit: 2
      }

      exptd_partial_query = %{
        page: 20,
        limit: 300
      }

      exptd_float_query = %{
        page: 200
      }

      assert exptd_empty_query ===
               ScraperRouterUtils.transform_search_articles_query_params(empty_query)

      assert exptd_full_query ===
               ScraperRouterUtils.transform_search_articles_query_params(full_query)

      assert exptd_partial_query ===
               ScraperRouterUtils.transform_search_articles_query_params(partial_query)

      assert exptd_float_query ===
               ScraperRouterUtils.transform_search_articles_query_params(float_query)
    end

    test "should fail with no string query" do
      no_string_query = %{
        limit: -3
      }

      assert_raise FunctionClauseError, fn ->
        ScraperRouterUtils.transform_search_articles_query_params(no_string_query)
      end
    end

    test "ignores not known fields" do
      strange_fields_query = %{
        test_field_1: "245",
        page: "-4",
        limit: "999",
        test_field_n: "56.4"
      }

      exptd_strange_fields_query = %{
        test_field_1: "245",
        page: -4,
        limit: 999,
        test_field_n: "56.4"
      }

      assert exptd_strange_fields_query ===
               ScraperRouterUtils.transform_search_articles_query_params(strange_fields_query)
    end

    test "ignores strage values for page and limit" do
      strange_values = %{
        page: "strange_page24",
        limit: "-45 strange limit"
      }

      exptd_strange_values = strange_values

      assert exptd_strange_values ===
               ScraperRouterUtils.transform_search_articles_query_params(strange_values)
    end
  end
end
