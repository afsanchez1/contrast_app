alias NewspaperScraper.Core.ElPaisScraper
alias NewspaperScraper.Core.ElMundoScraper

import Config

config :newspaper_scraper,
  el_pais_base_url: "https://elpais.com",
  el_pais_api_url: "/pf/api/v3/content/fetch/enp-search-results",
  el_mundo_base_url: "https://www.elmundo.es/",
  el_mundo_api_url: "https://ariadna.elmundo.es/buscador/archivo.html",
  scrapers: [
    ElPaisScraper
  ]
