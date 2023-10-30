defmodule NewspaperScraper.Client.ElPaisMockServer do
  alias NewspaperScraper.Utils.Test.TestUtils
  require Logger
  use Plug.Router
  use Agent

  @agent_name :el_pais_agent

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  def init(opts) do
    Logger.info("Server running on: http://localhost:#{opts[:port]}")

    resources = TestUtils.read_and_parse_JSON!("./resources/el_pais_responses.json", [keys: :atoms])

    Agent.start_link(fn -> resources end, name: @agent_name)
  end

  get "/search_articles" do
    query_params =
      fetch_query_params(conn).query_params

    {:ok, transformed_query} = Jason.decode(query_params["query"])

    topic = transformed_query["q"]

    resources = Agent.get(@agent_name, & &1)

    raw_res =
      case topic do
        "null_resp" -> resources.search_articles.invalid_resps.null_resp
        _ -> resources.search_articles.valid_resp
      end

    {:ok, res} = Jason.encode(raw_res)

    conn = put_resp_content_type(conn, "application/json")
    send_resp(conn, 200, res)
  end
end
