require "minitest/autorun"
require "pathname"

class SourceHygieneTest < Minitest::Test
  ROOT = Pathname.new(File.expand_path("..", __dir__))

  def test_root_does_not_contain_review_artifacts
    artifact_patterns = [
      "edge-*.png",
      "motion-*.png",
      "__live_style.css",
      ".edge-*"
    ]

    found = artifact_patterns.flat_map { |pattern| Dir.glob(ROOT.join(pattern).to_s) }.sort
    assert_equal [], found.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  end

  def test_shared_markup_has_no_inline_event_handlers
    checked_files = Dir.glob(ROOT.join("{_includes,_layouts,team,publications,research,news,contact}", "**", "*.{html,md}").to_s)
    offenders = checked_files.select do |path|
      File.read(path).match?(/\son[a-z]+=/i)
    end

    assert_equal [], offenders.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  end

  def test_default_layout_loads_molstar_conditionally
    layout = File.read(ROOT.join("_layouts/default.html"))

    assert_includes layout, "{% assign has_molstar = false %}"
    assert_includes layout, "{% if has_molstar %}"
    assert_match(/molstar\.css/, layout)
    assert_match(/molstar-viewer\.js/, layout)
  end

  def test_default_layout_exposes_skip_link_and_main_target
    layout = File.read(ROOT.join("_layouts/default.html"))

    assert_includes layout, 'href="#main-content"'
    assert_includes layout, '<main id="main-content">'
  end

  def test_noncritical_card_images_use_loading_and_decoding_hints
    publication_image = File.read(ROOT.join("_includes/publications/card-image.html"))
    team_card = File.read(ROOT.join("_includes/team-card.html"))
    molstar = File.read(ROOT.join("_includes/molstar-viewer.html"))

    assert_includes publication_image, 'loading="'
    assert_includes publication_image, 'decoding="async"'
    assert_includes team_card, 'loading="lazy"'
    assert_includes team_card, 'decoding="async"'
    assert_includes molstar, 'loading="lazy"'
    assert_includes molstar, 'decoding="async"'
  end

  def test_shared_image_templates_use_informative_alt_text
    team_card = File.read(ROOT.join("_includes/team-card.html"))
    molstar = File.read(ROOT.join("_includes/molstar-viewer.html"))
    archive_card = File.read(ROOT.join("_includes/publications/card-archive.html"))
    featured_card = File.read(ROOT.join("_includes/publications/card-featured.html"))
    book_card = File.read(ROOT.join("_includes/publications/card-book.html"))

    assert_includes team_card, 'alt="Photo of {{ member.name }}"'
    assert_includes molstar, 'alt="Poster preview for {{ viewer_title }}"'
    assert_includes archive_card, "{% assign image_alt = 'Visual for ' | append: publication.title %}"
    assert_includes featured_card, "{% assign image_alt = 'Visual for ' | append: publication.title %}"
    assert_includes book_card, "{% assign cover_alt = 'Cover of ' | append: publication.title %}"
  end

  def test_mobile_navigation_uses_details_summary_markup
    mobile_nav = File.read(ROOT.join("_includes/site-navigation-mobile.html"))

    assert_includes mobile_nav, "<details"
    assert_includes mobile_nav, "<summary"
  end

  def test_publication_filters_use_fieldset_and_native_checkboxes
    publications_page = File.read(ROOT.join("publications/index.md"))

    assert_includes publications_page, "<fieldset"
    assert_includes publications_page, "<legend"
    assert_includes publications_page, 'type="checkbox"'
  end
end
