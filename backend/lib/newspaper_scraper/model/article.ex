defmodule NewspaperScraper.Model.Article do
  @art_keys [
    :newspaper,
    :headline,
    :subheadline,
    :authors,
    :last_date_time,
    :body,
    :url
  ]
  @derive {Jason.Encoder, only: @art_keys}
  @enforce_keys @art_keys
  defstruct @art_keys
end
