require "minitest/autorun"
require "tmpdir"
require "fileutils"

require_relative "../lib/lab_site/embed_validator"

class EmbedValidatorTest < Minitest::Test
  def setup
    @root = File.expand_path("..", __dir__)
  end

  def test_current_repo_embed_blocks_are_valid
    validator = LabSite::EmbedValidator.new(root: @root)

    assert_empty validator.validate
  end

  def test_reports_missing_required_fields
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "_data"))
      File.write(File.join(dir, "_data", "structures.yml"), { "known-structure" => { "id" => "known-structure", "source" => "/assets/structures/example.pdb", "format" => "pdb" } }.to_yaml)
      FileUtils.mkdir_p(File.join(dir, "research"))
      File.write(File.join(dir, "research", "example.md"), <<~MARKDOWN)
        ---
        layout: default
        title: Example
        embeds:
          - type: molstar
          - type: document
        ---

        Example body.
      MARKDOWN

      validator = LabSite::EmbedValidator.new(root: dir)
      errors = validator.validate

      assert_includes errors, "research/example.md embed #1 must set `structure_id` for a Mol* block"
      assert_includes errors, "research/example.md embed #2 must set either `file` or `url` for a document block"
    end
  end
end
