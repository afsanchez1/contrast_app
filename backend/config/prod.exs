alias NewspaperScraper.Core.ElPaisScraper

import Config

config :newspaper_scraper,
  el_pais_base_url: "https://elpais.com",
  el_pais_api_url: "/pf/api/v3/content/fetch/enp-search-results",
  scrapers: [
    ElPaisScraper
  ]
