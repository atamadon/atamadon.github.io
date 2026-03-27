require "json"
require "minitest/autorun"
require "set"
require "yaml"

class FeaturedPublicationsConfigTest < Minitest::Test
  def setup
    root = File.expand_path("..", __dir__)
    @config = YAML.load_file(File.join(root, "_data", "featured_publications.yml")) || {}
    @publications = JSON.parse(File.read(File.join(root, "_data", "generated", "publications.json")))
  end

  def test_featured_publication_ids_are_unique_and_resolve
    ids = @config["featured_publication_ids"]

    assert_kind_of Array, ids
    assert ids.all? { |id| id.is_a?(String) && !id.strip.empty? }, "featured_publication_ids must contain non-empty strings"
    assert_equal ids.uniq, ids, "featured_publication_ids must not contain duplicates"

    publication_ids = @publications.map { |publication| publication["id"] }.to_set
    missing = ids.reject { |id| publication_ids.include?(id) }

    assert_empty missing, "featured_publication_ids contain unknown generated publication IDs: #{missing.join(', ')}"
  end
end
