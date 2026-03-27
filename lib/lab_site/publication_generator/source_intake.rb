module LabSite
  class PublicationGenerator
    module SourceIntake
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

      private

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
    end
  end
end
