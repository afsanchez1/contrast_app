defmodule NewspaperScraper.Utils.Managers.ScraperManagerUtils do
  alias NewspaperScraper.Boundary.Managers.ScraperRequestHandler
  alias NewspaperScraper.Boundary.Managers.ScraperParsingHandlerSupervisor
  alias NewspaperScraper.Boundary.Managers.ScraperEventManager

  def build_children(req_handlers) do
    {child_req_handlers, names} = build_req_handlers(req_handlers)

    [{ScraperEventManager, []}] ++
      child_req_handlers ++
      [{ScraperParsingHandlerSupervisor, subscription_names: names}]
  end

  def build_req_handlers(req_handlers) do
    names =
      for num <- 1..req_handlers do
        (to_string(ScraperRequestHandler) <> "_" <> to_string(num))
        |> String.to_atom()
      end

    children =
      Enum.map(
        names,
        fn name ->
          Supervisor.child_spec({ScraperRequestHandler, name: name}, id: name)
        end
      )

    {children, names}
  end
end
