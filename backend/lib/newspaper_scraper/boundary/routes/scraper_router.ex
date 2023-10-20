defmodule NewspaperScraper.Boundary.Routes.ScraperRouter do
  alias NewspaperScraper.Boundary.ScraperManager
  alias NewspaperScraper.Utils.Routes.RouterUtils

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
    conn_params = fetch_query_params(conn)

    with %{"topic" => topic, "page" => page, "limit" => limit} <- conn_params.params,
         parsed_art_summs when is_list(parsed_art_summs) <-
           ScraperManager.search_articles(topic, page, limit),
         {:ok, res} <- Jason.encode(parsed_art_summs) do
      send_resp(conn, 200, res)
    else
      error ->
        {:ok, error_res} = RouterUtils.transform_error(error) |> Jason.encode()
        send_resp(conn, 400, error_res)
    end
  end

  get "/get_article" do
    conn_params = fetch_query_params(conn)
    %{"url" => url} = conn_params.params

    {:ok, res} =
      ScraperManager.get_article(url)
      |> dbg()
      |> Jason.encode()

    send_resp(conn, 200, res)
  end

  match(_, do: send_resp(conn, 404, "Not Found"))
end
