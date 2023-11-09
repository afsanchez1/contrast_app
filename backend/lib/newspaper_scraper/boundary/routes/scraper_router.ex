defmodule NewspaperScraper.Boundary.Routes.ScraperRouter do
  alias NewspaperScraper.Utils.Routes.RouterUtils
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

  # ===================================================================================

  defp transform_search_articles_query_params(query) do
    for {key, value} <- query, into: %{} do
      cond do
        key === :page or key === :limit ->
          case Integer.parse(value) do
            {num, _rem} -> {key, num}
            _ -> {key, value}
          end

        true ->
          {key, value}
      end
    end
  end

  # ===================================================================================
  # Scraper routes
  # ===================================================================================

  get "/search_articles" do
    query_params =
      fetch_query_params(conn).query_params
      |> RouterUtils.transform_query_params()
      |> transform_search_articles_query_params()

    with parsed_art_summs when is_list(parsed_art_summs) <-
           ScraperAPI.search_articles(query_params),
         transformed <- Enum.map(parsed_art_summs, &RouterUtils.transform_error/1),
         {:ok, res} <- Jason.encode(transformed) do
      send_resp(conn, 200, res)
    else
      error ->
        transformed_error = RouterUtils.transform_error(error)

        case Jason.encode(transformed_error) do
          {:ok, parsed_res} -> send_resp(conn, 400, parsed_res)
          {:error, _} -> send_resp(conn, 500, "internal server error")
        end
    end
  end

  # ---------------------------------------------------------------------------------

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

  # ---------------------------------------------------------------------------------

  match(_, do: send_resp(conn, 404, "not found"))
end
