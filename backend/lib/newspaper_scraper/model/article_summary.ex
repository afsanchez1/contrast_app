defmodule NewspaperScraper.Model.ArticleSummary do
  @art_sum_keys [
    :newspaper,
    :authors,
    :title,
    :excerpt,
    :date_time,
    :url
  ]
  @derive {Jason.Encoder, only: @art_sum_keys}
  @enforce_keys @art_sum_keys
  defstruct @art_sum_keys
end
