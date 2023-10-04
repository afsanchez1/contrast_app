defmodule NewspaperScraper.Model.Author do
  @author_keys [
    :name,
    :url
  ]
  @derive {Jason.Encoder, only: @author_keys}
  @enforce_keys @author_keys
  defstruct @author_keys
end
