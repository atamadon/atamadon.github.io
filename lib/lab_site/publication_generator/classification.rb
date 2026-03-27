module LabSite
  class PublicationGenerator
    module Classification
      def normalize_doi(value)
        return nil if value.nil?

        value.to_s.sub(%r{\Ahttps?://(?:dx\.)?doi\.org/}i, "").strip
      end

      def extract_doi(value)
        return nil unless value

        match = value.to_s.match(%r{10\.\d{4,9}/[-._;()/:A-Z0-9]+}i)
        match&.[](0)
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

      private

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
    end
  end
end
