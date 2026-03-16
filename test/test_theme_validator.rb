require "fileutils"
require "minitest/autorun"
require "tmpdir"
require "yaml"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/theme_validator"

class ThemeValidatorTest < Minitest::Test
  def setup
    @root = File.expand_path("..", __dir__)
  end

  def test_current_repo_theme_and_site_settings_are_valid
    validator = LabSite::ThemeValidator.new(root: @root)

    assert_empty validator.validate
  end

  def test_reports_invalid_motion_and_missing_logo
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "_data"))
      File.write(File.join(dir, "_data", "site.yml"), site_yaml(logo: "/assets/logos/missing-logo.png"))
      File.write(File.join(dir, "_data", "theme.yml"), theme_yaml(scale: 3))

      errors = LabSite::ThemeValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("motion.scale must be a number between 0 and 2") })
      assert(errors.any? { |error| error.include?("brand.logo references missing file") })
    end
  end

  def test_reports_invalid_header_subtitle_url
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "_data"))
      File.write(File.join(dir, "_data", "site.yml"), site_yaml(logo: "https://example.edu/logo.png", subtitle_url: "not-a-url"))
      File.write(File.join(dir, "_data", "theme.yml"), theme_yaml(scale: 1))

      errors = LabSite::ThemeValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("header.subtitles[0].url must be a relative path or absolute URL") })
    end
  end

  private

  def site_yaml(logo:, subtitle_url: "https://example.edu")
    {
      "name" => "Example Lab",
      "header" => {
        "title" => {
          "label" => "Example Lab",
          "url" => "/"
        },
        "subtitles" => [
          {
            "label" => "Example University",
            "url" => subtitle_url
          }
        ]
      },
      "brand" => { "logo" => logo },
      "contact" => { "email" => "lab@example.edu" },
      "accessibility" => {
        "report_url" => "https://example.edu/report",
        "support_email" => "support@example.edu"
      },
      "governance" => {
        "privacy_url" => "https://example.edu/privacy",
        "nondiscrimination_url" => "https://example.edu/nondiscrimination"
      }
    }.to_yaml
  end

  def theme_yaml(scale:)
    {
      "layout" => { "content_width" => "72rem" },
      "radius" => { "card" => "1rem", "pill" => "999px" },
      "shadows" => {
        "light_card" => "0 18px 40px rgba(0, 38, 118, 0.08)",
        "light_card_hover" => "0 22px 48px rgba(0, 38, 118, 0.13)",
        "dark_card" => "0 18px 40px rgba(0, 0, 0, 0.34)",
        "dark_card_hover" => "0 22px 48px rgba(0, 0, 0, 0.42)"
      },
      "motion" => { "enabled" => true, "scale" => scale },
      "colors" => {
        "light" => color_group("#002676", "#ffffff"),
        "dark" => color_group("#8db7ff", "#08121f")
      }
    }.to_yaml
  end

  def color_group(primary, surface)
    {
      "berkeley_blue" => primary,
      "berkeley_gold" => "#fdb515",
      "accent_blue" => primary,
      "accent_gold" => "#fc9313",
      "ink_900" => "#1f1f1f",
      "ink_700" => "#4a4a4a",
      "line_300" => "rgba(0, 38, 118, 0.18)",
      "surface_0" => surface,
      "surface_50" => "#f7f9fc",
      "surface_100" => "#eef3f8",
      "surface_tint" => "#edf3fb",
      "header_bg" => primary,
      "header_surface" => "rgba(0, 38, 118, 0.96)",
      "header_border" => "rgba(255, 255, 255, 0.12)",
      "header_text" => "#ffffff",
      "header_muted" => "rgba(255, 255, 255, 0.78)",
      "theme_toggle_ring" => "rgba(253, 181, 21, 0.42)",
      "body_gradient_top" => "rgba(253, 181, 21, 0.08)",
      "body_gradient_mid" => "rgba(0, 38, 118, 0.04)"
    }
  end
end
