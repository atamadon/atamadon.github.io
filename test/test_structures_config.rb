require "minitest/autorun"
require "yaml"

class StructuresConfigTest < Minitest::Test
  def setup
    @root = File.expand_path("..", __dir__)
    @structures = YAML.safe_load(File.read(File.join(@root, "_data/structures.yml")), aliases: true)
  end

  def test_structure_entries_include_required_fields
    @structures.each do |_key, value|
      assert(value["id"])
      assert(value["source"])
      assert(value["format"])
    end
  end

  def test_local_structure_assets_exist
    @structures.each do |_key, value|
      source_path = File.join(@root, value["source"].sub(%r{\A/}, ""))
      poster_path = File.join(@root, value["poster_image"].sub(%r{\A/}, ""))
      assert(File.exist?(source_path), "missing structure source #{source_path}")
      assert(File.exist?(poster_path), "missing structure poster #{poster_path}")
    end
  end
end
