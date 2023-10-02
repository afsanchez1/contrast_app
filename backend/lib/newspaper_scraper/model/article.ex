defmodule NewspaperScraper.Model.Article do
  @art_keys [
    :newspaper,
    :topic,
    :headline,
    :subheadline,
    :authors,
    :date_time,
    :location,
    :body,
    :url
  ]
  @derive {Jason.Encoder, only: @art_keys}
  @enforce_keys @art_keys
  defstruct @art_keys
end
