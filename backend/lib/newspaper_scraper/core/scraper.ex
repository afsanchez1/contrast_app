defmodule Scraper do
  @type http_response :: Tesla.Env.result()
  @type json :: {:ok, String.t()}
  @type json_encode_error :: %Jason.EncodeError{__exception__: true, message: String.t()}
  @type url :: String.t()

  @doc """
  Searches articles based on a topic
  """
  @callback search_articles(topic :: String.t(), page :: integer(), limit :: integer()) ::
              http_response() | {:error, atom()}

  @doc """
  Parses the search results to a JSON
  """
  @callback parse_search_results(res :: http_response()) :: json() | json_encode_error()

  @doc """
  Gets the article HTML document
  """
  @callback get_article(url :: url()) :: http_response() | {:error, atom()}

  @doc """
  Converts the article HTML to a JSON
  """
  @callback parse_article(res :: http_response()) :: json() | json_encode_error()
end
