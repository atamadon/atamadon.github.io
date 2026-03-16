require "cgi"
require "fileutils"
require "json"
require "net/http"
require "uri"
require "yaml"
require "time"

require_relative "front_matter"

module LabSite
  class PublicationGenerator
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

    def normalize_openalex_work(work, image_resolver: method(:discover_image_for_source))
      doi = normalize_doi(work["doi"] || work.dig("ids", "doi"))
      source_url = doi ? "https://doi.org/#{doi}" : resolve_source_url(work)
      venue = resolve_venue(work)
      type, subtype, display_type = classify_record_type(
        raw_type: work["type_crossref"] || work["type"],
        title: work["title"],
        venue: venue,
        doi: doi,
        source_url: source_url
      )
      image_data = source_url ? resolve_image_metadata(source_url, image_resolver) : {}

      {
        "id" => publication_id(title: work["title"], doi: doi),
        "title" => work["title"],
        "type" => type,
        "subtype" => subtype,
        "display_type" => display_type,
        "date" => work["publication_date"] || work["from_publication_date"] || "#{work['publication_year']}-01-01",
        "authors" => Array(work["authorships"]).filter_map { |entry| entry.dig("author", "display_name") },
        "source_url" => source_url,
        "doi" => doi,
        "venue" => venue,
        "source_provider" => "openalex",
        "abstract" => reconstruct_abstract(work["abstract_inverted_index"]),
        "keywords" => resolve_keywords(work),
        "image_url" => image_data[:url],
        "image_source" => image_data[:source],
        "open_access_url" => resolve_open_access_url(work),
        "citation" => nil
      }
    end

    def normalize_legacy_publication(front_matter)
      source_url = front_matter["external_url"] || front_matter["url"]
      doi = extract_doi(front_matter["doi"] || source_url || front_matter["citation"])
      venue = legacy_venue(front_matter["citation"], front_matter["type"])
      type, subtype, display_type = classify_record_type(
        raw_type: front_matter["type"],
        title: front_matter["title"],
        venue: venue,
        doi: doi,
        source_url: source_url,
        legacy: true
      )

      {
        "id" => publication_id(title: front_matter["title"], doi: doi),
        "title" => front_matter["title"],
        "type" => type,
        "subtype" => subtype,
        "display_type" => display_type,
        "date" => front_matter["date"].to_s,
        "authors" => Array(front_matter["authors"]),
        "source_url" => source_url,
        "doi" => doi,
        "venue" => venue,
        "source_provider" => "legacy_seed",
        "abstract" => nil,
        "keywords" => Array(front_matter["keywords"]),
        "image_url" => front_matter["figure"] || front_matter["cover"],
        "image_source" => (front_matter["figure"] || front_matter["cover"]) ? "legacy_asset" : nil,
        "open_access_url" => nil,
        "citation" => front_matter["citation"]
      }
    end

    def apply_overrides(records)
      records.filter_map do |record|
        override = combined_override_for(record)
        merged = record.merge(override)
        if override["image_override"]
          merged["image_url"] = override["image_override"]
          merged["image_source"] = "override"
        end

        unless merged["image_url"]
          merged["image_url"] = placeholder_image(merged["type"])
          merged["image_source"] = "placeholder"
        end
        next if merged["hide"]

        merged
      end
    end

    private

    def curate_records(records)
      kept_records = []
      removed_low_value = 0

      records.each do |record|
        normalized = normalize_record(record)
        if suppress_record?(normalized)
          removed_low_value += 1
          next
        end

        kept_records << normalized
      end

      deduped_records, removed_duplicates = deduplicate_records(kept_records)
      log_status("Removed #{removed_low_value} low-value records and #{removed_duplicates} duplicate manifestations.")
      deduped_records
    end

    def fetch_openalex_publications
      return [] unless @live

      query_name = @site_config.dig("publications", "query_name")
      log_status("Resolving OpenAlex author for #{query_name}.")
      author_id = configured_or_discovered_author_id
      unless author_id
        log_status("No OpenAlex author match found. Continuing with legacy seed data only.")
        return []
      end

      log_status("Using OpenAlex author #{author_id}.")

      cursor = "*"
      records = []
      page = 0
      normalized_count = 0

      loop do
        uri = URI("#{OPENALEX_BASE_URL}/works")
        uri.query = URI.encode_www_form(
          {
            filter: "author.id:#{author_id}",
            per_page: 200,
            sort: "publication_date:desc",
            cursor: cursor,
            mailto: @site_config.dig("contact", "email")
          }
        )

        payload = fetch_json(uri)
        break unless payload

        page += 1
        results = Array(payload["results"])
        log_status("Fetched OpenAlex page #{page} (#{results.length} works). Resolving metadata...")

        results.each do |work|
          records << normalize_openalex_work(work)
          normalized_count += 1
          next unless (normalized_count % OPENALEX_PROGRESS_INTERVAL).zero?

          log_status("Resolved #{normalized_count} OpenAlex works so far.")
        end

        next_cursor = payload.dig("meta", "next_cursor")
        break if next_cursor.nil? || next_cursor == cursor

        cursor = next_cursor
      end

      log_status("Fetched #{records.length} OpenAlex works total.")
      records
    rescue StandardError => error
      log_status("OpenAlex fetch failed: #{error.class}: #{error.message}. Continuing with legacy seed data only.")
      []
    end

    def configured_or_discovered_author_id
      configured = @site_config.dig("publications", "author_id")
      return configured unless configured.nil? || configured.empty?

      query_name = @site_config.dig("publications", "query_name")
      affinity = @site_config.dig("publications", "affiliation_contains").to_s.downcase
      uri = URI("#{OPENALEX_BASE_URL}/authors")
      uri.query = URI.encode_www_form(
        {
          search: query_name,
          per_page: 25,
          mailto: @site_config.dig("contact", "email")
        }
      )

      payload = fetch_json(uri)
      return nil unless payload

      candidates = Array(payload["results"])
      best = candidates
        .sort_by do |candidate|
          institutions = institutions_for(candidate)
          affinity_match = institutions.any? { |name| name.downcase.include?(affinity) } ? 0 : 1
          works_count = candidate["works_count"].to_i
          [affinity_match, -works_count]
        end
        .first

      best&.fetch("id", nil)
    end

    def institutions_for(candidate)
      values = []
      last_known = candidate.dig("last_known_institution", "display_name")
      values << last_known if last_known
      Array(candidate["affiliations"]).each do |affiliation|
        values << affiliation.dig("institution", "display_name")
      end
      values.compact
    end

    def fetch_json(uri)
      response = fetch_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def fetch_response(uri, redirects_remaining: MAX_REDIRECTS)
      fetch_response_with_headers(uri, redirects_remaining: redirects_remaining)
    end

    def fetch_response_with_headers(uri, redirects_remaining: MAX_REDIRECTS, headers: {})
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 15, open_timeout: 10) do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "lab-website-publications-generator"
        headers.each { |key, value| request[key] = value }
        response = http.request(request)
        return response unless response.is_a?(Net::HTTPRedirection) && redirects_remaining.positive?

        location = response["location"]
        return response unless location

        next_uri = URI.join(uri.to_s, location)
        fetch_response_with_headers(next_uri, redirects_remaining: redirects_remaining - 1, headers: headers)
      end
    end

    def classify_record_type(raw_type:, title:, venue:, doi:, source_url:, legacy: false)
      normalized_type = raw_type.to_s.downcase.tr("_", "-").strip

      if whole_book_type?(normalized_type, legacy: legacy)
        return ["book", "book", "Book"]
      end

      if book_part_type?(normalized_type, title, venue, doi)
        subtype = reference_entry?(normalized_type, title, doi) ? "reference_entry" : "book_chapter"
        return ["journal", subtype, display_type_for(subtype)]
      end

      if conference_type?(normalized_type, venue)
        return ["journal", "conference", display_type_for("conference")]
      end

      if preprint_record?(venue, doi, source_url)
        return ["journal", "preprint", display_type_for("preprint")]
      end

      if repository_record?(venue, source_url)
        return ["journal", "repository", display_type_for("repository")]
      end

      ["journal", "journal_article", display_type_for("journal_article")]
    end

    def normalize_doi(value)
      return nil if value.nil?

      value.to_s.sub(%r{\Ahttps?://(?:dx\.)?doi\.org/}i, "").strip
    end

    def resolve_source_url(work)
      work.dig("primary_location", "landing_page_url") ||
        work.dig("best_oa_location", "landing_page_url") ||
        work.dig("ids", "openalex")
    end

    def resolve_open_access_url(work)
      work.dig("best_oa_location", "landing_page_url") ||
        work.dig("best_oa_location", "pdf_url")
    end

    def resolve_venue(work)
      work.dig("primary_location", "source", "display_name") ||
        work.dig("host_venue", "display_name")
    end

    def resolve_keywords(work)
      keywords = Array(work["keywords"]).filter_map { |entry| entry["display_name"] }
      return keywords unless keywords.empty?

      Array(work["concepts"]).first(5).filter_map { |entry| entry["display_name"] }
    end

    def reconstruct_abstract(inverted_index)
      return nil unless inverted_index.is_a?(Hash) && !inverted_index.empty?

      words = Array.new(inverted_index.values.flatten.max + 1)
      inverted_index.each do |word, positions|
        Array(positions).each { |position| words[position] = word }
      end
      words.compact.join(" ")
    end

    def resolve_image_metadata(source_url, image_resolver)
      cached = @cache.dig("resolved_images", source_url)
      if cached
        @stats["resolved_image_cache_hits"] += 1
        return symbolize_cache_entry(cached)
      end

      @stats["resolved_image_cache_misses"] += 1
      image_value = image_resolver.call(source_url)
      normalized = if image_value.is_a?(Hash)
        { url: image_value[:url] || image_value["url"], source: image_value[:source] || image_value["source"] }
      elsif image_value
        { url: image_value, source: "cover_or_preview" }
      else
        {}
      end

      store_cache_entry("resolved_images", source_url, normalized)
      normalized
    end

    def discover_image_for_source(source_url)
      final_url, html = fetch_html_document(source_url)
      return nil unless html

      figure_candidate = extract_figure_image(final_url, html)
      validated_figure = validate_image_candidate(figure_candidate)
      return validated_figure if validated_figure

      cover_candidate = extract_cover_image(final_url, html)
      validate_image_candidate(cover_candidate)
    rescue StandardError
      nil
    end

    def legacy_publications
      Dir.glob(File.join(@root, "_publications", "*.md")).sort.map do |path|
        front_matter, = LabSite::FrontMatter.parse_file(path)
        normalize_legacy_publication(front_matter)
      end
    end

    def legacy_venue(citation, type)
      return nil unless citation

      segments = citation.split(". ").map(&:strip)
      return segments[-2] if type.to_s == "journal" && segments.length >= 3

      segments.last&.split(";")&.first
    end

    def merge_publications(primary_records, fallback_records)
      merged = {}

      fallback_records.each do |record|
        merged[record["id"]] = record
      end

      primary_records.each do |record|
        merged[record["id"]] = merged.fetch(record["id"], {}).merge(record) do |_key, existing, incoming|
          incoming.nil? || incoming == [] ? existing : incoming
        end
      end

      merged.values
    end

    def sort_records(records)
      records.sort_by do |record|
        [
          record["date"].to_s,
          record.fetch("sort_weight", 0),
          record["title"].to_s.downcase
        ]
      end.reverse
    end

    def placeholder_image(type)
      case type
      when "book"
        "/assets/images/publications/publication-placeholder-book.svg"
      else
        "/assets/images/publications/publication-placeholder-journal.svg"
      end
    end

    def extract_doi(value)
      return nil unless value

      match = value.to_s.match(%r{10\.\d{4,9}/[-._;()/:A-Z0-9]+}i)
      match&.[](0)
    end

    def normalize_record(record)
      normalized = record.dup
      normalized["title"] = normalized["title"].to_s.strip
      normalized["venue"] = normalized["venue"].to_s.strip
      normalized["doi"] = normalize_doi(normalized["doi"])
      normalized["source_url"] = normalized["source_url"].to_s.strip
      normalized["subtype"] ||= inferred_subtype_for_existing_record(normalized)
      normalized["display_type"] ||= display_type_for(normalized["subtype"])
      normalized
    end

    def suppress_record?(record)
      LOW_VALUE_TITLE_PATTERNS.any? { |pattern| record["title"].to_s.match?(pattern) }
    end

    def deduplicate_records(records)
      removed_duplicates = 0
      deduped = records.group_by { |record| dedupe_key(record) }.values.flat_map do |group|
        next group if group.length <= 1

        ranked = group.sort_by { |record| dedupe_rank(record) }.reverse
        best = ranked.first.dup
        duplicates = ranked.drop(1)

        if duplicates.all? { |record| duplicate_manifestation?(best, record) }
          aliases = ([best["id"]] + duplicates.map { |record| record["id"] }).compact.uniq
          best["id_aliases"] = aliases if aliases.length > 1
          removed_duplicates += duplicates.length
          [best]
        else
          group
        end
      end

      [deduped, removed_duplicates]
    end

    def duplicate_manifestation?(canonical, candidate)
      return false unless canonical["type"] == candidate["type"]

      low_quality_record?(candidate) || record_score(canonical) >= record_score(candidate)
    end

    def dedupe_rank(record)
      [
        record_score(record),
        record["date"].to_s,
        record["title"].to_s.downcase
      ]
    end

    def record_score(record)
      score = case record["subtype"]
              when "book" then 70
              when "journal_article" then 60
              when "conference" then 50
              when "book_chapter" then 35
              when "reference_entry" then 25
              when "preprint" then 15
              when "repository" then 10
              else 20
              end
      score += 10 unless record["venue"].to_s.empty?
      score += 5 unless record["doi"].to_s.empty?
      score += 5 if record["subtype"] == "book" && !record["venue"].to_s.match?(/eBooks/i)
      score -= 10 if record["subtype"] == "book" && record["venue"].to_s.match?(/eBooks/i)
      score -= 10 if low_quality_record?(record)
      score
    end

    def low_quality_record?(record)
      preprint_record?(record["venue"], record["doi"], record["source_url"]) ||
        repository_record?(record["venue"], record["source_url"]) ||
        record["venue"].to_s.empty?
    end

    def dedupe_key(record)
      title = record["title"].to_s
      title = title.split(/\s*[:\-]\s*/, 2).first if record["type"] == "book"

      title
        .gsub(/<[^>]+>/, " ")
        .downcase
        .gsub(/[^a-z0-9]+/, " ")
        .strip
        .squeeze(" ")
    end

    def inferred_subtype_for_existing_record(record)
      _type, subtype, = classify_record_type(
        raw_type: record["type"],
        title: record["title"],
        venue: record["venue"],
        doi: record["doi"],
        source_url: record["source_url"],
        legacy: record["source_provider"] == "legacy_seed"
      )
      subtype
    end

    def whole_book_type?(normalized_type, legacy:)
      WHOLE_BOOK_TYPES.include?(normalized_type) || (legacy && normalized_type == "book")
    end

    def book_part_type?(normalized_type, title, venue, doi)
      BOOK_PART_TYPES.include?(normalized_type) ||
        reference_entry?(normalized_type, title, doi) ||
        venue.to_s.match?(/eBooks/i)
    end

    def conference_type?(normalized_type, venue)
      CONFERENCE_TYPES.include?(normalized_type) ||
        venue.to_s.match?(/\bconference\b|\bproceedings\b|\bworkshop\b/i)
    end

    def reference_entry?(normalized_type, title, doi)
      normalized_type == "reference-entry" ||
        normalized_type == "encyclopedia-entry" ||
        title.to_s.split.size <= 3 ||
        (title.to_s.split.size <= 5 && doi.to_s.match?(%r{\A10\.1007/978-[^/]+_[0-9a-z-]+\z}i))
    end

    def preprint_record?(venue, doi, source_url)
      PREPRINT_VENUE_PATTERNS.any? { |pattern| venue.to_s.match?(pattern) } ||
        PREPRINT_DOI_PREFIXES.any? { |prefix| doi.to_s.downcase.start_with?(prefix) } ||
        source_url.to_s.match?(/arxiv|ssrn|chemrxiv|biorxiv|medrxiv/i)
    end

    def repository_record?(venue, source_url)
      REPOSITORY_VENUE_PATTERNS.any? { |pattern| venue.to_s.match?(pattern) } ||
        source_url.to_s.match?(/figshare|zenodo|dspace|pubmed/i)
    end

    def display_type_for(subtype)
      case subtype
      when "book" then "Book"
      when "journal_article" then "Journal article"
      when "conference" then "Conference paper"
      when "book_chapter" then "Book chapter"
      when "reference_entry" then "Reference entry"
      when "preprint" then "Preprint"
      when "repository" then "Repository record"
      else "Publication"
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

    def extract_figure_image(source_url, html)
      structured_candidate = extract_structured_figure_image(source_url, html)
      return structured_candidate if structured_candidate

      best_candidate = nil

      html.to_enum(:scan, /<img\b[^>]*>/im).each do
        tag = Regexp.last_match[0]
        offset = Regexp.last_match.begin(0)
        attributes = extract_html_attributes(tag)
        image_url = image_url_from_attributes(attributes, source_url)
        next unless image_url && likely_content_image?(image_url, attributes)

        score = figure_image_score(attributes, html, offset)
        next if score <= 0

        if best_candidate.nil? || score > best_candidate[:score]
          best_candidate = { url: image_url, source: "figure_1", score: score }
        end
      end

      best_candidate && { url: best_candidate[:url], source: best_candidate[:source] }
    end

    def extract_structured_figure_image(source_url, html)
      patterns = [
        /href=["']([^"']*figure\/image\?download[^"']*(?:g001|fig1)[^"']*)["']/i,
        /href=["']([^"']*figure\/image\?[^"']*(?:g001|fig1)[^"']*)["']/i,
        /src=["']([^"']*figure\/image\?[^"']*(?:g001|fig1)[^"']*)["']/i
      ]

      patterns.each do |pattern|
        match = html.match(pattern)
        next unless match

        return { url: URI.join(source_url, CGI.unescapeHTML(match[1])).to_s, source: "figure_1" }
      rescue URI::InvalidURIError
        next
      end

      nil
    end

    def extract_cover_image(source_url, html)
      meta_tags = html.scan(/<meta\b[^>]*>/i)
      meta_tags.each do |tag|
        attributes = extract_html_attributes(tag)
        value = (attributes["property"] || attributes["name"]).to_s.downcase
        next unless %w[citation_cover_image og:image twitter:image].include?(value)
        next unless attributes["content"]

        return { url: URI.join(source_url, attributes["content"]).to_s, source: "cover_or_preview" }
      end

      best_candidate = nil
      html.to_enum(:scan, /<img\b[^>]*>/im).each do
        tag = Regexp.last_match[0]
        attributes = extract_html_attributes(tag)
        image_url = image_url_from_attributes(attributes, source_url)
        next unless image_url && likely_content_image?(image_url, attributes)

        score = cover_image_score(attributes)
        next if score <= 0

        if best_candidate.nil? || score > best_candidate[:score]
          best_candidate = { url: image_url, source: "cover_or_preview", score: score }
        end
      end

      best_candidate && { url: best_candidate[:url], source: best_candidate[:source] }
    end

    def extract_html_attributes(tag)
      tag.scan(/([A-Za-z_:.-]+)=["']([^"']+)["']/).each_with_object({}) do |(key, value), attributes|
        attributes[key.downcase] = CGI.unescapeHTML(value)
      end
    end

    def image_url_from_attributes(attributes, source_url)
      candidates = [
        attributes["data-zoom-src"],
        attributes["data-hi-res-src"],
        attributes["data-full-src"],
        attributes["data-src"],
        attributes["src"],
        first_src_from_srcset(attributes["srcset"])
      ].compact

      raw_url = candidates.find do |value|
        image_file_path?(value) || known_image_endpoint?(value) || value.start_with?("http") || value.start_with?("/")
      end
      return nil unless raw_url

      URI.join(source_url, raw_url).to_s
    rescue URI::InvalidURIError
      nil
    end

    def first_src_from_srcset(srcset)
      return nil unless srcset

      srcset.split(",").map(&:strip).first&.split&.first
    end

    def figure_image_score(attributes, html, offset)
      context_start = [offset - 1200, 0].max
      context = html[context_start, 2400].to_s
      attribute_text = attributes.values.join(" ")
      score = 0
      score += 16 if figure_one_marker?(attribute_text)
      score += 14 if figure_one_marker?(context)
      score += 6 if attribute_text.match?(/\bfig(?:ure)?[-_\s]?1\b/i)
      score
    end

    def cover_image_score(attributes)
      attribute_text = attributes.values.join(" ")
      return -10 if figure_one_marker?(attribute_text)

      score = 0
      score += 8 if attribute_text.match?(/\bcover\b/i)
      score += 6 if attribute_text.match?(/\bjournal\b/i)
      score += 4 if attribute_text.match?(/\barticle\b|\bgraphical abstract\b/i)
      score
    end

    def figure_one_marker?(text)
      text.to_s.match?(/\b(?:figure|fig\.?)\s*1\b/i)
    end

    def likely_content_image?(image_url, attributes)
      combined = [image_url, attributes["alt"], attributes["class"], attributes["id"]].compact.join(" ").downcase
      return false if combined.match?(/logo|sprite|icon|avatar|orcid|favicon/)

      image_file_path?(image_url) || known_image_endpoint?(image_url)
    end

    def image_file_path?(value)
      value.to_s.match?(/\.(?:png|jpe?g|gif|webp|avif|svg)(?:\?|#|$)/i)
    end

    def known_image_endpoint?(value)
      value.to_s.match?(%r{article/(?:figure/image|file\?type=thumbnail)}i) ||
        value.to_s.match?(%r{/retrieve/pii/.+/gr\d+}i) ||
        value.to_s.match?(%r{/cms/asset/}i)
    end

    def fetch_html_document(source_url, redirects_remaining: MAX_REDIRECTS)
      uri = URI(source_url)
      response = fetch_response(uri, redirects_remaining: redirects_remaining)
      return [source_url, nil] unless response.is_a?(Net::HTTPSuccess)

      html = response.body.to_s
      redirect_target = extract_html_redirect_target(source_url, html)
      if redirect_target && redirects_remaining.positive? && redirect_target != source_url
        return fetch_html_document(redirect_target, redirects_remaining: redirects_remaining - 1)
      end

      [source_url, html]
    end

    def extract_html_redirect_target(source_url, html)
      meta_refresh = html.match(/http-equiv=["']refresh["'][^>]*content=["'][^"']*url=['"]?([^"'>]+)['"]?["']/i)
      if meta_refresh
        candidate = CGI.unescapeHTML(meta_refresh[1].strip)
        redirect_target = redirect_target_from_candidate(source_url, candidate)
        return redirect_target if redirect_target
      end

      redirect_url = html.match(/name=["']redirectURL["'][^>]*value=["']([^"']+)["']/i)
      return unless redirect_url

      CGI.unescapeHTML(redirect_url[1])
    end

    def redirect_target_from_candidate(source_url, candidate)
      uri = URI.join(source_url, candidate)
      params = CGI.parse(uri.query.to_s)
      redirect_param = params["Redirect"]&.first || params["redirect"]&.first || params["url"]&.first
      return CGI.unescapeHTML(redirect_param) if redirect_param

      uri.to_s
    rescue URI::InvalidURIError
      nil
    end

    def validate_image_candidate(candidate)
      return nil unless candidate && candidate[:url]

      image_url = candidate[:url].to_s
      cached = @cache.dig("validated_images", image_url)
      if cached
        @stats["validated_image_cache_hits"] += 1
        return cached["accepted"] ? candidate.merge(validation_metadata_from_cache(cached)) : nil
      end

      @stats["validated_image_cache_misses"] += 1
      validation = compute_image_validation(image_url)
      store_cache_entry("validated_images", image_url, validation)
      validation["accepted"] ? candidate.merge(validation_metadata_from_cache(validation)) : nil
    end

    def compute_image_validation(image_url)
      if junk_image_url?(image_url)
        return rejected_image_validation("junk_url")
      end

      uri = URI(image_url)
      response = fetch_response_with_headers(
        uri,
        redirects_remaining: MAX_REDIRECTS,
        headers: { "Range" => "bytes=0-#{IMAGE_METADATA_BYTES - 1}" }
      )
      return rejected_image_validation("fetch_failed") unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPPartialContent)

      content_type = response["content-type"].to_s.split(";").first.to_s.downcase
      return rejected_image_validation("not_image", content_type: content_type) unless content_type.start_with?("image/")

      body = response.body.to_s.b
      width, height = image_dimensions_from_binary(body, content_type)
      if width && height && width < 80 && height < 80
        return rejected_image_validation("too_small", content_type: content_type, width: width, height: height)
      end

      {
        "accepted" => true,
        "reason" => "ok",
        "content_type" => content_type,
        "width" => width,
        "height" => height,
        "content_length" => response["content-length"]&.to_i,
        "checked_at" => Time.now.utc.iso8601
      }
    rescue StandardError => error
      rejected_image_validation("validation_error", error: "#{error.class}: #{error.message}")
    end

    def rejected_image_validation(reason, extra = {})
      {
        "accepted" => false,
        "reason" => reason,
        "checked_at" => Time.now.utc.iso8601
      }.merge(extra)
    end

    def junk_image_url?(image_url)
      JUNK_IMAGE_PATTERNS.any? { |pattern| image_url.match?(pattern) }
    end

    def image_dimensions_from_binary(body, content_type)
      return png_dimensions(body) if content_type.include?("png")
      return gif_dimensions(body) if content_type.include?("gif")
      return jpeg_dimensions(body) if content_type.include?("jpeg") || content_type.include?("jpg")

      [nil, nil]
    end

    def png_dimensions(body)
      return [nil, nil] unless body.bytesize >= 24 && body.start_with?("\x89PNG".b)

      [body[16, 4].unpack1("N"), body[20, 4].unpack1("N")]
    end

    def gif_dimensions(body)
      return [nil, nil] unless body.bytesize >= 10 && body.start_with?("GIF".b)

      body[6, 4].unpack("vv")
    end

    def jpeg_dimensions(body)
      return [nil, nil] unless body.bytesize >= 4 && body.getbyte(0) == 0xFF && body.getbyte(1) == 0xD8

      index = 2
      while index + 9 < body.bytesize
        index += 1 while index < body.bytesize && body.getbyte(index) != 0xFF
        break if index + 9 >= body.bytesize

        marker = body.getbyte(index + 1)
        index += 2
        next if marker == 0xD8 || marker == 0xD9

        length = body[index, 2]&.unpack1("n")
        break unless length && length >= 2 && index + length <= body.bytesize

        if (0xC0..0xC3).cover?(marker) || (0xC5..0xC7).cover?(marker) || (0xC9..0xCB).cover?(marker) || (0xCD..0xCF).cover?(marker)
          height, width = body[index + 3, 4].unpack("nn")
          return [width, height]
        end

        index += length
      end

      [nil, nil]
    end

    def validation_metadata_from_cache(validation)
      {
        width: validation["width"],
        height: validation["height"],
        content_type: validation["content_type"]
      }.compact
    end

    def load_cache
      return default_cache unless File.exist?(@cache_path)

      parsed = JSON.parse(File.read(@cache_path))
      return default_cache unless parsed["version"] == CACHE_VERSION

      default_cache.merge(parsed)
    rescue StandardError
      default_cache
    end

    def default_cache
      {
        "version" => CACHE_VERSION,
        "resolved_images" => {},
        "validated_images" => {}
      }
    end

    def write_cache
      return unless @cache_dirty

      FileUtils.mkdir_p(File.dirname(@cache_path))
      temp_path = "#{@cache_path}.tmp"
      File.write(temp_path, JSON.pretty_generate(@cache) + "\n")
      FileUtils.mv(temp_path, @cache_path)
      @cache_dirty = false
    end

    def store_cache_entry(namespace, key, value)
      @cache[namespace][key] = value
      @cache_dirty = true
    end

    def symbolize_cache_entry(entry)
      {
        url: entry["url"],
        source: entry["source"],
        width: entry["width"],
        height: entry["height"],
        content_type: entry["content_type"]
      }.compact
    end

    def log_status(message)
      @logger.call(message)
    end
  end
end
