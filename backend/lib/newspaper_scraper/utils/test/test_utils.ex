defmodule NewspaperScraper.Utils.Test.TestUtils do
  def read_and_parse_JSON!(file_path, opts \\ []) do
    with {:ok, body} <- File.read(file_path),
         {:ok, parsed_json} <- Jason.decode(body, opts),
         do: parsed_json,
         else: (e -> raise e)
  end
end
