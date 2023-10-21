defmodule NewspaperScraper.Boundary.Routes.ScraperRouter do
  alias NewspaperScraper.Utils.Routes.RouterUtils
  alias NewspaperScraper.Utils.Routes.ScraperRouterUtils
  alias NewspaperScraper.Boundary.ScraperAPI

  use Plug.Router

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/search_articles" do
    query_params =
      fetch_query_params(conn).query_params
      |> RouterUtils.transform_query_params()
      |> ScraperRouterUtils.transform_search_articles_query_params()

    with parsed_art_summs when is_list(parsed_art_summs) <-
           ScraperAPI.search_articles(query_params),
         {:ok, res} <- Jason.encode(parsed_art_summs) do
      send_resp(conn, 200, res)
    else
      error ->
        {:ok, error_res} = RouterUtils.transform_error(error) |> Jason.encode()
        send_resp(conn, 400, error_res)
    end
  end

  get "/get_article" do
    query_params =
      fetch_query_params(conn).query_params
      |> RouterUtils.transform_query_params()

    with {:ok, parsed_art} <- ScraperAPI.get_article(query_params),
         {:ok, res} <- Jason.encode(parsed_art) do
      send_resp(conn, 200, res)
    else
      error ->
        {:ok, error_res} = RouterUtils.transform_error(error) |> Jason.encode()
        send_resp(conn, 400, error_res)
    end
  end

  match(_, do: send_resp(conn, 404, "Not Found"))
end
