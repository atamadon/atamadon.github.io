require "fileutils"
require "minitest/autorun"
require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/team_onboarding_export"

class TeamOnboardingExportTest < Minitest::Test
  def test_target_path_and_rendering_follow_public_schema
    export = LabSite::TeamOnboardingExport.new(
      "public_profile" => {
        "berkeley_username" => "jdoe",
        "name" => "Jordan Doe",
        "role" => "Graduate Student",
        "status" => "PhD Student",
        "groups" => ["ai"],
        "email" => "jdoe@berkeley.edu",
        "image" => "/assets/images/team/jdoe.jpg",
        "active" => true,
        "sort_order" => 200,
        "bio_short" => "Works on mechanobiology.",
        "show_email" => false,
        "github" => "https://github.com/jdoe"
      }
    )

    assert_equal("/_team/grad/jdoe.md", export.target_team_path)
    rendered = export.render_team_entry
    assert_includes(rendered, "berkeley_username: jdoe")
    assert_includes(rendered, "groups:")
    assert_includes(rendered, "show_email: false")
    assert_includes(rendered, "github: https://github.com/jdoe")
  end

  def test_warnings_flag_invalid_group_and_missing_required_fields
    export = LabSite::TeamOnboardingExport.new(
      "public_profile" => {
        "berkeley_username" => "jdoe",
        "role" => "Graduate Student",
        "groups" => ["unknown-group"],
        "active" => true
      }
    )

    warnings = export.warnings
    assert(warnings.any? { |warning| warning.include?("Missing required public field `name`") })
    assert(warnings.any? { |warning| warning.include?("Unknown public group `unknown-group`") })
  end

  def test_load_file_reads_yaml_export
    Dir.mktmpdir do |dir|
      path = File.join(dir, "approved-export.yml")
      File.write(path, <<~YAML)
        public_profile:
          berkeley_username: jdoe
          name: Jordan Doe
          role: Postdoc
          status: Postdoctoral Researcher
          groups:
            - microbiome
          email: jdoe@berkeley.edu
          image: /assets/images/team/jdoe.jpg
          active: true
          sort_order: 120
      YAML

      export = LabSite::TeamOnboardingExport.load_file(path)
      assert_equal("/_team/postdoc/jdoe.md", export.target_team_path)
      assert_empty(export.warnings)
    end
  end
end
