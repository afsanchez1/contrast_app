defmodule NewspaperScraper.Utils.Test.TestUtils do
  def read_and_parse_JSON!(file_path, opts \\ []) do
    body = File.read!(file_path)

    Jason.decode!(body, opts)
  end
end
