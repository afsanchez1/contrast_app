alias NewspaperScraper.Core.ElPaisScraper
import Config

config :newspaper_scraper,
  el_pais_base_url: "http://localhost:8081",
  el_pais_api_url: "/search_articles",
  el_pais_resources_path: "./priv/test/el_pais",
  el_pais_search_responses_path: "./priv/test/el_pais/el_pais_search_responses.json",
  scrapers: [
    ElPaisScraper
  ]
