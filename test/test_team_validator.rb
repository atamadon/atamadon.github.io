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

  def test_inactive_alumnus_can_omit_email_groups_and_image
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "alumni/example-person.md", <<~MARKDOWN)
        ---
        berkeley_username: example-person
        name: Example Person
        role: Alumni
        status: Former Lab Member
        active: false
        leave_date: 2024-05-01
        current_position: Scientist at Example Lab
        ---
      MARKDOWN

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert_equal([], errors)
    end
  end

  def test_active_member_requires_email_groups_and_image
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "grad/jdoe.md", <<~MARKDOWN)
        ---
        berkeley_username: jdoe
        name: Example User
        role: Graduate Student
        status: PhD Student
        active: true
        join_date: 2023-08-15
        ---
      MARKDOWN

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("missing required field `email`") })
      assert(errors.any? { |error| error.include?("missing required field `groups`") })
      assert(errors.any? { |error| error.include?("missing required field `image`") })
    end
  end

  def test_show_email_requires_email_even_for_inactive_records
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "alumni/jdoe.md", <<~MARKDOWN)
        ---
        berkeley_username: jdoe
        name: Example User
        role: Alumni
        status: Former Lab Member
        active: false
        leave_date: 2024-05-01
        show_email: true
        ---
      MARKDOWN

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("missing required field `email`") })
    end
  end

  def test_active_member_requires_join_date
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "grad/jdoe.md", <<~MARKDOWN)
        ---
        berkeley_username: jdoe
        name: Example User
        role: Graduate Student
        status: PhD Student
        email: example@berkeley.edu
        groups:
          - molecular-dynamics
        image: /assets/images/team/profile-placeholder.svg
        active: true
        ---
      MARKDOWN

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("missing required field `join_date`") })
    end
  end

  def test_inactive_member_requires_leave_date
    Dir.mktmpdir do |dir|
      write_team_entry(dir, "alumni/jdoe.md", <<~MARKDOWN)
        ---
        berkeley_username: jdoe
        name: Example User
        role: Alumni
        status: Former Lab Member
        active: false
        ---
      MARKDOWN

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert(errors.any? { |error| error.include?("missing required field `leave_date`") })
    end
  end

  def test_active_member_can_omit_bio
    Dir.mktmpdir do |dir|
      image_path = File.join(dir, "assets", "images", "team", "profile-placeholder.svg")
      FileUtils.mkdir_p(File.dirname(image_path))
      File.write(image_path, "<svg></svg>")

      write_team_entry(dir, "grad/jdoe.md", <<~MARKDOWN)
        ---
        berkeley_username: jdoe
        name: Example User
        role: Graduate Student
        status: PhD Student
        email: example@berkeley.edu
        groups:
          - molecular-dynamics
        image: /assets/images/team/profile-placeholder.svg
        active: true
        join_date: 2023-08-15
        ---
      MARKDOWN

      errors = LabSite::TeamValidator.new(root: dir).validate

      assert_equal([], errors)
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
      #{active ? 'join_date: 2023-08-15' : 'leave_date: 2024-05-01'}
      bio_short: Example bio
      #{extras}
      ---
    MARKDOWN
  end
end
