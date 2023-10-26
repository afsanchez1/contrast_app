defmodule NewspaperScraper.Model.Author do
  @author_keys [
    :name,
    :url
  ]
  @derive {Jason.Encoder, only: @author_keys}
  @enforce_keys [:name]
  defstruct @author_keys
end
