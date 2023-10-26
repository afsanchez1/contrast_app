defmodule NewspaperScraper.Core.ElPaisScraperTest do
  alias NewspaperScraper.Core.ElPaisScraper
  alias NewspaperScraper.Model.Author
  use ExUnit.Case, async: true
  doctest ElPaisScraper

  @page 1
  @limit 2

  setup_all do
    {:ok, search_res} = ElPaisScraper.search_articles("ucrania", @page, @limit)
    {:ok, search_res: search_res}
  end

  describe "scraper_check/1" do
    test "url doesn't belong to scraper" do
      url = "https://www.elmundo.es/internacional"
      assert {:error, "invalid url"} === ElPaisScraper.scraper_check(url)
    end

    test "url belongs to scraper" do
      url =
        "https://cincodias.elpais.com/cincodias/2023/09/08/legal/1694176476_943900.html?rel=buscador_noticias"

      assert :ok === ElPaisScraper.scraper_check(url)
    end
  end

  describe "ElPaisScraper.search_articles/3" do
    test "search is not empty", context do
      search_res = context[:search_res]
      assert length(search_res) !== 0
    end

    test "search result has proper size", context do
      search_res = context[:search_res]
      assert length(search_res) === 2
    end

    test "search results have expected format", context do
      expected_keys = [
        "authors",
        "title",
        "excerpt",
        "url",
        "updatedTs"
      ]

      search_res = context[:search_res]

      Enum.each(
        search_res,
        fn article ->
          keys = Map.keys(article)

          Enum.each(
            expected_keys,
            fn expected_key ->
              assert Enum.member?(keys, expected_key)
            end
          )
        end
      )
    end
  end

  describe "ElPaisScraper.parse_search_results/1" do
    test "parsing result has same size", context do
      search_result = context[:search_res]
      {:ok, parsing_result} = ElPaisScraper.parse_search_results(search_result)

      assert length(search_result) === length(parsing_result)
    end

    test "parsing works properly" do
      search_result = [
        %{
          "authors" => [
            %{
              "name" => "María Sahuquillo",
              "url" => "https://elpais.com/autor/maria-rodriguez-sahuquillo/"
            },
            %{"name" => "Cristian Segura", "url" => "https://elpais.com/autor/cristian-segura/"}
          ],
          "excerpt" =>
            "Kiev asiste con preocupación al bloqueo de ayudas en el Congreso de EE UU y a las grietas en el frente europeo en torno a las consecuencias de su adhesión a la UE",
          "infoFromArcio" => %{"subtype" => "noticia"},
          "kicker" => "Guerra de Rusia en Ucrania",
          "kickerUrl" => "https://elpais.com/noticias/ofensiva-rusia-ucrania/",
          "photo" => %{
            "height" => 311,
            "mime-type" => "image/jpeg",
            "uri" =>
              "https://imagenes.elpais.com/resizer/hKE_rNj0kIDCnEmW7ptFdZXCFHY=/414x311/filters:focal(3960x1379:3970x1389)/cloudfront-eu-central-1.images.arcpublishing.com/prisa/655OSMEVZJHS3FVIDRGALYUEOM.jpg",
            "width" => 414
          },
          "title" => "Ucrania teme que el apoyo de Occidente se resquebraje",
          "updatedTs" => 1_696_770_910,
          "url" =>
            "https://elpais.com/internacional/2023-10-08/ucrania-teme-que-el-apoyo-de-occidente-se-resquebraje.html"
        }
      ]

      {:ok, parsing_result} = ElPaisScraper.parse_search_results(search_result)
      article_summary = Enum.at(parsing_result, 0)

      assert article_summary.newspaper === "El País"

      assert article_summary.authors === [
               %NewspaperScraper.Model.Author{
                 name: "María Sahuquillo",
                 url: "https://elpais.com/autor/maria-rodriguez-sahuquillo/"
               },
               %NewspaperScraper.Model.Author{
                 name: "Cristian Segura",
                 url: "https://elpais.com/autor/cristian-segura/"
               }
             ]

      assert article_summary.title === "Ucrania teme que el apoyo de Occidente se resquebraje"

      assert article_summary.excerpt ===
               "Kiev asiste con preocupación al bloqueo de ayudas en el Congreso de EE UU y a las grietas en el frente europeo en torno a las consecuencias de su adhesión a la UE"

      assert article_summary.date_time === "2023-10-08T13:15:10Z"

      assert article_summary.url ===
               "https://elpais.com/internacional/2023-10-08/ucrania-teme-que-el-apoyo-de-occidente-se-resquebraje.html"

      assert article_summary.is_premium === true
    end

    test "parsing should fail" do
      bad_formatted_result = [
        %{
          "bad_authors" => [
            %{
              "name" => "María Sahuquillo",
              "url" => "https://elpais.com/autor/maria-rodriguez-sahuquillo/"
            },
            %{"name" => "Cristian Segura", "url" => "https://elpais.com/autor/cristian-segura/"}
          ],
          "bad_date" => 1_696_770_910
        }
      ]

      assert {:error, _} = ElPaisScraper.parse_search_results(bad_formatted_result)
    end

    test "premium check works" do
      search_result = [
        %{
          "authors" => [
            %{
              "name" => "María Sahuquillo",
              "url" => "https://elpais.com/autor/maria-rodriguez-sahuquillo/"
            },
            %{"name" => "Cristian Segura", "url" => "https://elpais.com/autor/cristian-segura/"}
          ],
          "excerpt" =>
            "Kiev asiste con preocupación al bloqueo de ayudas en el Congreso de EE UU y a las grietas en el frente europeo en torno a las consecuencias de su adhesión a la UE",
          "title" => "Ucrania teme que el apoyo de Occidente se resquebraje",
          "updatedTs" => 1_696_770_910,
          "url" =>
            "https://elpais.com/internacional/2023-10-08/ucrania-teme-que-el-apoyo-de-occidente-se-resquebraje.html"
        },
        %{
          "authors" => [%{"name" => "El País", "url" => "https://elpais.com/autor/el-pais/"}],
          "excerpt" =>
            "Rusia ataca con misiles instalaciones portuarias en Odesa | Un niño de 10 años y su abuela mueren en Járkov al impactar un proyectil en el centro de la ciudad | La ONU envía un equipo de investigación a indagar sobre la matanza de Hroza",
          "title" => "Guerra de Ucrania y Rusia, en directo",
          "updatedTs" => 1_696_768_205,
          "url" =>
            "https://elpais.com/internacional/2023-10-08/guerra-de-ucrania-y-rusia-en-directo.html"
        }
      ]

      {:ok, parsing_result} = ElPaisScraper.parse_search_results(search_result)
      premium_article = Enum.at(parsing_result, 0)
      non_premium_article = Enum.at(parsing_result, 1)

      assert premium_article.is_premium
      assert not non_premium_article.is_premium
    end
  end

  describe "ElPaisScraper.get_article/1" do
    test "gets the article properly" do
      assert {:ok, _} =
               ElPaisScraper.get_article(
                 "https://elpais.com/internacional/2023-10-08/guerra-de-ucrania-y-rusia-en-directo.html"
               )
    end

    test "get article should fail" do
      assert {:error, _} =
               ElPaisScraper.get_article(
                 "https://elpais.udc/internacional/2023-10-08/guerra-de-ucrania-y-rusia-en-directo.html"
               )
    end
  end

  describe "ElPaisScraper.parse_article/1" do
    test "parses opinion article properly" do
      parsing_result =
        with {:ok, {html_doc, url}} <-
               ElPaisScraper.get_article(
                 "https://elpais.com/opinion/2023-10-08/guerra-entre-hamas-e-israel.html"
               ),
             {:ok, parsing_result} <- ElPaisScraper.parse_article(html_doc, url),
             do: parsing_result,
             else: (error -> error)

      exptd_headline = "Hamás reta a Israel"

      exptd_subheadline =
        "La mediación internacional es urgente para detener un baño de sangre que puede contagiar a otros países de la región"

      exptd_authors = [
        %Author{
          name: "El País",
          url: "https://elpais.com/autor/el-pais/#?rel=author_top"
        }
      ]

      exptd_date_time = "2023-10-08T05:00:00+02:00"

      exptd_first_paragraph =
        %{p:
         "El tan temido enfrentamiento entre Israel y Hamás se desencadenó ayer cuando la organización palestina lanzó un ataque combinado sin precedentes contra el Estado judío que tuvo como primera respuesta un bombardeo israelí masivo de la Franja. La explosión de violencia amenaza con extenderse a otras zonas de la región —el primer balance provisional es el de centenares de muertos y heridos en ambos bandos, en su mayoría civiles— y las consecuencias políticas no pueden ser otras que la inestabilidad y el reforzamiento de las posiciones más radicales que consideran la paz no ya inalcanzable, sino una solución no deseada a un conflicto enquistado desde hace ya 56 años."}

      exptd_last_paragraph =
        %{p:
         "Es perentoria una mediación internacional efectiva que detenga el baño de sangre y su extensión a zonas como Cisjordania —ayer hubo choques en Jerusalén Este— y la frontera con Líbano que provocarían una situación fuera de control. Tanto Israel como Hamás tienen poderosos aliados sobre los que recae esta responsabilidad ineludible. Pero además resulta inaplazable abordar un conflicto al que el mundo se ha acostumbrado. Lo urgente es que los cañones callen, pero lo necesario es alcanzar una solución para que lo hagan para siempre."}

      assert exptd_headline === parsing_result.headline
      assert exptd_subheadline === parsing_result.subheadline
      assert exptd_authors === parsing_result.authors
      assert exptd_date_time === parsing_result.last_date_time
      assert exptd_first_paragraph === parsing_result.body |> Enum.at(0)
      assert exptd_last_paragraph === parsing_result.body |> Enum.at(-1)
    end

    test "parses article with headings properly" do
      parsing_result =
        with {:ok, {html_doc, url}} <-
               ElPaisScraper.get_article(
                 "https://cincodias.elpais.com/cincodias/2023/09/08/legal/1694176476_943900.html?rel=buscador_noticias"
               ),
             {:ok, parsing_result} <- ElPaisScraper.parse_article(html_doc, url),
             do: parsing_result,
             else: (error -> error)

      exptd_headline = "Caso Rubiales: los entresijos del TAD"

      exptd_subheadline =
        "Los juristas del Tribunal Administrativo del Deporte decidirán sobre la sanción por faltas graves mientras la querella por agresión sexual sigue su curso"

      exptd_authors = [
        %Author{
          name: "Patricia Esteban",
          url: "https://cincodias.elpais.com/autor/patricia-esteban-baena/#?rel=author_top"
        }
      ]

      exptd_date_time = "2023-09-11T10:35:41+02:00"

      exptd_first_paragraph =
        %{p:
         "El culebrón desatado tras la victoria de la selección femenina de fútbol en el Mundial por el caso Rubiales ha puesto en primera plana la labor del Tribunal Administrativo del Deporte (TAD), el organismo que resolverá el expediente abierto contra el expresidente de la RFEF (Real Federación Española de Fútbol). Los juristas que lo componen decidirán sobre la posible sanción a Luis Rubiales por el beso propinado a la jugadora Jenni Hermoso y por los actos indecorosos protagonizados tanto en el palco de autoridades como en la entrega de trofeos. En la noche del 10 de septiembre, el dirigente ha dimitido de todos sus cargos tras la formalización por la Fiscalía de una querella por agresión sexual y coacciones ante la Audiencia Nacional. Rubiales había sido apartado provisionalmente por la FIFA."}

      exptd_last_paragraph =
        %{p:
         "Como organizador del Mundial, explica Alberto Palomar, la FIFA tiene competencia para castigar la actuación del expresidente de los futbolistas españoles. La entidad suiza, agrega Rosalía Ortega, ha actuado en base a una “norma estrictamente privada, como es el artículo 51 del Código Disciplinario de la FIFA”. Y es que, asegura la abogada, la decisión privada de la FIFA “es completamente compatible con una sanción en España del TAD, basada en la vulneración de normativa pública española como es la Ley del Deporte” y podría terminar en el TAS (Tribunal de Arbitraje Deportivo de Lausana). Un camino que no podrá recorrer la futura resolución sobre Rubiales, por tratarse de cuestiones, explica Maite Nadal “vedadas actualmente al arbitraje."}

      exptd_first_heading = %{h3: "Competencia"}

      assert exptd_headline === parsing_result.headline
      assert exptd_subheadline === parsing_result.subheadline
      assert exptd_authors === parsing_result.authors
      assert exptd_date_time === parsing_result.last_date_time
      assert exptd_first_paragraph === parsing_result.body |> Enum.at(0)
      assert exptd_last_paragraph === parsing_result.body |> Enum.at(-1)
      assert exptd_first_heading === parsing_result.body |> Enum.at(2)
    end

    test "should fail parsing premium article" do
      assert {:error, _err} =
               with(
                 {:ok, {html_doc, url}} <-
                   ElPaisScraper.get_article(
                     "https://elpais.com/internacional/2023-10-09/por-que-la-potente-israel-no-vio-venir-el-ataque-de-hamas.html"
                   ),
                 {:ok, parsing_result} <- ElPaisScraper.parse_article(html_doc, url),
                 do: parsing_result,
                 else: (error -> error)
               )
    end

    test "should fail parsing empty HTML" do
      html = ""
      url = "http://testurl.udc"

      assert {:error, _} = ElPaisScraper.parse_article(html, url)
    end

    test "should fail parsing HTML without requested info" do
      html = """
      <!DOCTYPE html>
      <html lang='es'>
      </html>
      """

      url = "http://testurl.udc"

      assert {:error, _} = ElPaisScraper.parse_article(html, url)
    end
  end
end

# TODO caso de prueba de autor sin url
