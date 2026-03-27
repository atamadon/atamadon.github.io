require "json"
require "minitest/autorun"
require "tmpdir"
require "fileutils"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/publication_generator"

class PublicationGeneratorTest < Minitest::Test
  def setup
    @generator = LabSite::PublicationGenerator.new(
      root: File.expand_path("..", __dir__),
      live: false,
      use_legacy_only: true
    )
  end

  def test_publication_id_prefers_doi
    id = @generator.publication_id(
      title: "Example Paper",
      doi: "10.1000/test-doi"
    )

    assert_equal "doi-10-1000-test-doi", id
  end

  def test_normalize_legacy_publication_uses_required_fields
    record = @generator.normalize_legacy_publication(
      {
        "title" => "Computational Modeling in Biomechanics",
        "type" => "book",
        "date" => "2010-04-01",
        "authors" => ["Mohammad R. K. Mofrad"],
        "citation" => "De S, Guilak F, Mofrad MRK (eds). Computational Modeling in Biomechanics. Springer Dordrecht; April 1, 2010.",
        "external_url" => "https://example.test/book",
        "cover" => "/cover.png",
        "keywords" => ["biomechanics"]
      }
    )

    assert_equal "book", record["type"]
    assert_equal "Springer Dordrecht", record["venue"]
    assert_equal "/cover.png", record["image_url"]
    assert_equal "legacy_seed", record["source_provider"]
  end

  def test_normalize_openalex_work_classifies_book_chapter_as_non_book
    record = @generator.normalize_openalex_work(
      {
        "title" => "Mechanotransduction and Its Role in Stem Cell Biology",
        "type_crossref" => "book-chapter",
        "publication_date" => "2009-01-01",
        "doi" => "https://doi.org/10.1007/978-1-60327-905-5_20",
        "authorships" => [],
        "primary_location" => {
          "landing_page_url" => "https://example.test/chapter",
          "source" => { "display_name" => "Humana Press eBooks" }
        }
      },
      image_resolver: ->(_url) { nil }
    )

    assert_equal "journal", record["type"]
    assert_equal "book_chapter", record["subtype"]
    assert_equal "Book chapter", record["display_type"]
  end

  def test_normalize_openalex_work_classifies_whole_book
    record = @generator.normalize_openalex_work(
      {
        "title" => "Cellular Mechanotransduction: Diverse Perspectives from Molecules to Tissues",
        "type_crossref" => "book",
        "publication_date" => "2009-11-23",
        "doi" => nil,
        "authorships" => [],
        "primary_location" => {
          "landing_page_url" => "https://example.test/book",
          "source" => { "display_name" => "Cambridge University Press" }
        }
      },
      image_resolver: ->(_url) { nil }
    )

    assert_equal "book", record["type"]
    assert_equal "book", record["subtype"]
    assert_equal "Book", record["display_type"]
  end

  def test_discover_image_for_source_prefers_figure_one_image
    html = <<~HTML
      <html>
        <head>
          <meta property="og:image" content="/covers/journal-cover.jpg">
        </head>
        <body>
          <figure id="fig1">
            <img src="/figures/figure1.png" alt="Figure 1">
            <figcaption>Figure 1. Main result.</figcaption>
          </figure>
        </body>
      </html>
    HTML

    image = @generator.send(:extract_figure_image, "https://example.test/article", html)

    assert_equal "https://example.test/figures/figure1.png", image[:url]
    assert_equal "figure_1", image[:source]
  end

  def test_extract_cover_image_falls_back_to_cover_or_preview
    html = <<~HTML
      <html>
        <head>
          <meta property="og:image" content="https://cdn.example.test/cover.jpg">
        </head>
        <body></body>
      </html>
    HTML

    image = @generator.send(:extract_cover_image, "https://example.test/article", html)

    assert_equal "https://cdn.example.test/cover.jpg", image[:url]
    assert_equal "cover_or_preview", image[:source]
  end

  def test_extract_figure_image_handles_plos_style_figure_links
    html = <<~HTML
      <div class="figure" data-doi="10.1371/journal.pone.0244430.g001">
        <a href="article/figure/image?download&amp;size=large&amp;id=10.1371/journal.pone.0244430.g001">
          <img src="article/figure/image?size=inline&amp;id=10.1371/journal.pone.0244430.g001" alt="thumbnail">
        </a>
        <div class="figcaption"><span>Fig 1.</span> Example caption.</div>
      </div>
    HTML

    image = @generator.send(:extract_figure_image, "https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0244430", html)

    assert_equal "https://journals.plos.org/plosone/article/figure/image?download&size=large&id=10.1371/journal.pone.0244430.g001", image[:url]
    assert_equal "figure_1", image[:source]
  end

  def test_extract_html_redirect_target_handles_meta_refresh_with_redirect_query
    html = <<~HTML
      <meta http-equiv="REFRESH" content="2; url='/retrieve/articleSelectPrefsTemp?Redirect=https%3A%2F%2Fcell.com%2Fbiophysj%2Fretrieve%2Fpii%2FS0006349524003916&amp;key=test'"/>
    HTML

    redirect_target = @generator.send(:extract_html_redirect_target, "https://linkinghub.elsevier.com/retrieve/pii/S0006349524003916", html)

    assert_equal "https://cell.com/biophysj/retrieve/pii/S0006349524003916", redirect_target
  end

  def test_validate_image_candidate_rejects_known_junk_logo_urls
    candidate = { url: "https://static.arxiv.org/static/browse/0.3.4/images/arxiv-logo-fb.png", source: "cover_or_preview" }

    assert_nil @generator.send(:validate_image_candidate, candidate)
  end

  def test_validate_image_candidate_uses_cached_result
    @generator.instance_variable_get(:@cache)["validated_images"]["https://example.test/image.png"] = {
      "accepted" => true,
      "reason" => "ok",
      "width" => 640,
      "height" => 480,
      "content_type" => "image/png"
    }

    candidate = @generator.send(:validate_image_candidate, { url: "https://example.test/image.png", source: "figure_1" })

    assert_equal "figure_1", candidate[:source]
    assert_equal 640, candidate[:width]
    assert_equal 1, @generator.stats["validated_image_cache_hits"]
  end

  def test_curate_records_removes_low_value_titles_and_prefers_published_version
    curated = @generator.send(
      :curate_records,
      [
        {
          "title" => "Author response for Example Paper",
          "type" => "journal",
          "subtype" => "journal_article",
          "date" => "2024-02-01"
        },
        {
          "title" => "Same Work",
          "type" => "journal",
          "subtype" => "preprint",
          "display_type" => "Preprint",
          "date" => "2023-01-01",
          "doi" => "10.1101/2023.01.01.123456",
          "venue" => ""
        },
        {
          "title" => "Same Work",
          "type" => "journal",
          "subtype" => "journal_article",
          "display_type" => "Journal article",
          "date" => "2024-01-01",
          "doi" => "10.1093/nar/gkae123",
          "venue" => "Nucleic Acids Research"
        }
      ]
    )

    assert_equal 1, curated.length
    assert_equal "Same Work", curated.first["title"]
    assert_equal "journal_article", curated.first["subtype"]
  end

  def test_curate_records_collapses_duplicate_book_manifestations
    curated = @generator.send(
      :curate_records,
      [
        {
          "title" => "Cellular Mechanotransduction: Diverse Perspectives from Molecules to Tissues",
          "type" => "book",
          "subtype" => "book",
          "display_type" => "Book",
          "date" => "2009-11-23",
          "venue" => "Cambridge University Press",
          "doi" => ""
        },
        {
          "title" => "Cellular Mechanotransduction",
          "type" => "book",
          "subtype" => "book",
          "display_type" => "Book",
          "date" => "2009-11-23",
          "venue" => "Cambridge University Press eBooks",
          "doi" => "10.1017/cbo9781139195874"
        }
      ]
    )

    assert_equal 1, curated.length
    assert_equal "Cellular Mechanotransduction: Diverse Perspectives from Molecules to Tissues", curated.first["title"]
  end

  def test_apply_overrides_prefers_image_override_and_respects_hide
    records = [
      { "id" => "visible", "type" => "journal", "title" => "Visible", "date" => "2024-01-01" },
      { "id" => "doi-10-1080-19491034-2024-2399247", "type" => "journal", "title" => "Visible 2", "date" => "2024-01-02" }
    ]

    generator = LabSite::PublicationGenerator.new(
      root: File.expand_path("..", __dir__),
      live: false,
      use_legacy_only: true
    )

    result = generator.apply_overrides(records)

    overridden = result.find { |record| record["id"] == "doi-10-1080-19491034-2024-2399247" }
    assert_equal "/assets/images/publications/kncl_a_2399247_f0001_oc.jpg", overridden["image_url"]
    assert_equal "override", overridden["image_source"]

    visible = result.find { |record| record["id"] == "visible" }
    assert_equal "/assets/images/publications/publication-placeholder-journal.svg", visible["image_url"]
    assert_equal "placeholder", visible["image_source"]
  end

  def test_apply_overrides_considers_id_aliases
    records = [
      {
        "id" => "canonical-id",
        "id_aliases" => ["cellular-mechanotransduction-diverse-perspectives-from-molecules-to-tissues"],
        "type" => "book",
        "title" => "Canonical Title",
        "date" => "2009-11-23"
      }
    ]

    result = @generator.apply_overrides(records)

    assert_equal true, result.first["featured"]
    assert_equal "Cell & Nuclear Biomechanics", result.first["research_area"]
  end

  def test_write_emits_json_array
    Dir.mktmpdir do |dir|
      output = File.join(dir, "publications.json")
      records = @generator.write(output_path: output)
      parsed = JSON.parse(File.read(output))

      assert_equal records.length, parsed.length
      assert_kind_of Array, parsed
    end
  end
end
