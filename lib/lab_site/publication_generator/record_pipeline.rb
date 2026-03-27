module LabSite
  class PublicationGenerator
    module RecordPipeline
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

      def sort_records(records)
        records.sort_by do |record|
          [
            record["date"].to_s,
            record.fetch("sort_weight", 0),
            record["title"].to_s.downcase
          ]
        end.reverse
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
    end
  end
end
