require "fileutils"
require "minitest/autorun"
require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/team_validator"

class TeamValidatorTest < Minitest::Test
  def test_duplicate_usernames_fail
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "grad/alice.md", front_matter("alice", active: false))
      write_team_entry(dir, "postdoc/alice.md", front_matter("alice", active: false))

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("Duplicate berkeley_username `alice`") })
    end
  end

  def test_active_member_requires_existing_image
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "pi/mofrad.md", front_matter("mofrad", active: true))

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("references missing image") })
    end
  end

  def test_inactive_member_can_skip_image_existence
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "grad/jdoe.md", front_matter("jdoe", active: false))

      errors = LabSite::TeamValidator.new(root: dir).validate

      refute(errors.any? { |error| error.include?("references missing image") })
    end
  end

  def test_filename_must_match_berkeley_username
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "pi/not-matching.md", front_matter("mofrad", active: false))

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("filename must match berkeley_username") })
    end
  end

  def test_show_email_must_be_boolean_when_present
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "grad/jdoe.md", front_matter("jdoe", active: false, extras: "show_email: maybe\n"))

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("must set `show_email` to true or false") })
    end
  end

  def test_optional_public_links_must_be_urls
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "grad/jdoe.md", front_matter("jdoe", active: false, extras: "github: not-a-url\n"))

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("invalid URL in `github`") })
    end
  end

  private

  def write_team_entry(root, relative_path, yaml)
    path = File.join(root, "_team", relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, yaml)
  end

  def front_matter(username, active:, extras: "")
    <<~MARKDOWN
      ---
      berkeley_username: #{username}
      name: Example User
      role: Graduate Student
      status: PhD Student
      email: example@berkeley.edu
      groups:
        - molecular-dynamics
      image: /assets/images/team/profile-placeholder.svg
      active: #{active}
      sort_order: 10
      bio_short: Example bio
      #{extras}
      ---
    MARKDOWN
  end
end
