defmodule Utils.Routes.RouterUtilsTest do
  alias NewspaperScraper.Utils.Routes.RouterUtils
  use ExUnit.Case, async: true

  describe "transform_error/1" do
    test "transforms errors properly" do
      string_error = {:error, "test error"}
      atom_error = {:error, :forbbiden_content}
      keyword_error = {:error, topic: "topic must be a string", page: "page must be an integer"}

      exptd_string_error = %{error: "test error"}
      exptd_atom_error = %{error: :forbbiden_content}
      exptd_keyword_error = %{error: [topic: "topic must be a string", page: "page must be an integer"]}

      assert exptd_string_error === RouterUtils.transform_error(string_error)
      assert exptd_atom_error === RouterUtils.transform_error(atom_error)
      assert exptd_keyword_error === RouterUtils.transform_error(keyword_error)
    end
  end
end
