defmodule NewspaperScraper.Model.Topic do
  @topic_keys [
    :name,
    :url
  ]
  @derive {Jason.Encoder, only: @topic_keys}
  @enforce_keys @topic_keys
  defstruct @topic_keys
end
