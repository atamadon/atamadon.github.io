require "cgi"
require "fileutils"
require "json"
require "net/http"
require "time"
require "uri"
require "yaml"

require_relative "front_matter"
require_relative "publication_generator/classification"
require_relative "publication_generator/source_intake"
require_relative "publication_generator/image_discovery"
require_relative "publication_generator/image_validation"
require_relative "publication_generator/record_pipeline"

module LabSite
  class PublicationGenerator
    include Classification
    include SourceIntake
    include ImageDiscovery
    include ImageValidation
    include RecordPipeline

    OPENALEX_BASE_URL = "https://api.openalex.org"
    OPENALEX_PROGRESS_INTERVAL = 50
    MAX_REDIRECTS = 5
    CACHE_VERSION = 1
    IMAGE_CACHE_PATH = ".cache/publication_generator/image_cache.json"
    IMAGE_METADATA_BYTES = 65_536
    WHOLE_BOOK_TYPES = %w[book monograph edited-book book-set].freeze
    BOOK_PART_TYPES = %w[book-part book-chapter book-section reference-entry entry encyclopedia-entry].freeze
    CONFERENCE_TYPES = %w[proceedings-article proceedings series conference conference-paper dissertation thesis report].freeze
    LOW_VALUE_TITLE_PATTERNS = [
      /\Aauthor response\b/i,
      /\bcontributors\b/i,
      /\blist of contributors\b/i,
      /\Apreface\z/i
    ].freeze
    REPOSITORY_VENUE_PATTERNS = [
      /figshare/i,
      /zenodo/i,
      /dspace/i,
      /pubmed central/i,
      /\Apubmed\z/i
    ].freeze
    PREPRINT_VENUE_PATTERNS = [
      /arxiv/i,
      /ssrn/i,
      /chemrxiv/i,
      /biorxiv/i,
      /medrxiv/i
    ].freeze
    PREPRINT_DOI_PREFIXES = %w[
      10.1101/
      10.21203/
      10.26434/
      10.48550/
    ].freeze
    JUNK_IMAGE_PATTERNS = [
      /arxiv[-_]?logo/i,
      /medrxiv.*logo/i,
      /ieee[_-]?logo/i,
      /logo[_-]?smedia/i,
      /\/assets\/img\//i,
      /\/sites\/default\/files\/images\/.*logo/i,
      /favicon/i,
      /sprite/i,
      /orcid/i
    ].freeze

    def initialize(root:, live: true, use_legacy_only: false, logger: nil)
      @root = root
      @live = live
      @use_legacy_only = use_legacy_only
      @logger = logger || ->(_message) {}
      @site_config = YAML.safe_load(File.read(File.join(root, "_data/site.yml")), aliases: true)
      @overrides = YAML.safe_load(File.read(File.join(root, "_data/publication_overrides.yml")), aliases: true) || {}
      @cache_path = File.join(root, IMAGE_CACHE_PATH)
      @cache = load_cache
      @cache_dirty = false
      @stats = Hash.new(0)
    end

    attr_reader :stats

    def call
      legacy_records = legacy_publications
      log_status("Loaded #{legacy_records.length} legacy seed publications.")

      records = if @use_legacy_only
        log_status("Using legacy seed publications only.")
        legacy_records
      else
        live_records = fetch_openalex_publications
        log_status("Merging #{live_records.length} OpenAlex records with legacy seed data.")
        merge_publications(live_records, legacy_records)
      end

      records = curate_records(records)
      log_status("Retained #{records.length} publication records after curation.")
      records = apply_overrides(records)
      log_status("Prepared #{records.length} publication records after overrides.")
      sort_records(records)
    end

    def write(output_path: nil)
      output_path ||= File.join(@root, @site_config.dig("publications", "output_path"))
      records = call
      temp_output_path = "#{output_path}.tmp"
      File.write(temp_output_path, JSON.pretty_generate(records) + "\n")
      FileUtils.mv(temp_output_path, output_path)
      write_cache
      records
    end

    def publication_id(title:, doi: nil)
      return "doi-#{slugify(doi)}" if doi && !doi.empty?

      slugify(title)
    end

    def slugify(value)
      value.to_s.downcase
        .gsub(%r{https?://}, "")
        .gsub(/[^a-z0-9]+/, "-")
        .gsub(/^-|-$/, "")
    end

    private

    def placeholder_image(type)
      case type
      when "book"
        "/assets/images/publications/publication-placeholder-book.svg"
      else
        "/assets/images/publications/publication-placeholder-journal.svg"
      end
    end

    def combined_override_for(record)
      aliases = Array(record["id_aliases"])
      keys = ([record["id"]] + aliases).compact.uniq

      keys.each_with_object({}) do |key, merged_override|
        override = @overrides.fetch(key, nil)
        merged_override.merge!(override) if override
      end
    end

    def log_status(message)
      @logger.call(message)
    end
  end
end
