defmodule NewspaperScraper.Boundary.Routes.ScraperRouter do
  alias NewspaperScraper.Boundary.ScraperManager
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
    %{"topic" => topic, "page" => page, "limit" => limit} = conn_params.params

    {:ok, res} =
      ScraperManager.search_articles(topic, page, limit)
      |> Jason.encode()

    send_resp(conn, 200, res)
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
