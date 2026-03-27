require "csv"
require "date"
require "rexml/document"
require "rexml/xpath"

module LabSite
  class WordpressExportInventory
    WP_NAMESPACE = { "wp" => "http://wordpress.org/export/1.2/" }.freeze
    LEDGER_CONTENT_TYPES = %w[post page].freeze

    attr_reader :source_path

    def self.load_file(path)
      new(File.read(path), source_path: path)
    end

    def initialize(xml, source_path: nil)
      @source_path = source_path
      @document = REXML::Document.new(xml)
    end

    def site_title
      text_at(@document, "/rss/channel/title")
    end

    def site_link
      text_at(@document, "/rss/channel/link")
    end

    def item_count
      items.length
    end

    def type_counts
      count_by { |item| item.fetch("post_type", "") }
    end

    def status_counts
      count_by { |item| item.fetch("status", "") }
    end

    def items_by_type(type)
      items.select { |item| item.fetch("post_type", "") == type }
    end

    def published_posts
      items.select { |item| item.fetch("post_type", "") == "post" && item.fetch("status", "") == "publish" }
    end

    def published_pages
      items.select { |item| item.fetch("post_type", "") == "page" && item.fetch("status", "") == "publish" }
    end

    def attachments_by_id
      @attachments_by_id ||= items.each_with_object({}) do |item, memo|
        next unless item.fetch("post_type", "") == "attachment"

        memo[item.fetch("post_id", "")] = item.fetch("attachment_url", "")
      end
    end

    def draft_ledger_rows
      items
        .select { |item| LEDGER_CONTENT_TYPES.include?(item.fetch("post_type", "")) }
        .map { |item| ledger_row_for(item) }
    end

    def write_ledger_csv(path)
      rows = draft_ledger_rows
      CSV.open(path, "w", write_headers: true, headers: rows.first&.keys || ledger_headers) do |csv|
        rows.each { |row| csv << row.values }
      end
    end

    private

    def items
      @items ||= begin
        rows = []
        REXML::XPath.each(@document, "/rss/channel/item") do |item|
          rows << {
            "title" => text_at(item, "title"),
            "link" => text_at(item, "link"),
            "post_id" => namespaced_text(item, "post_id"),
            "post_type" => namespaced_text(item, "post_type"),
            "status" => namespaced_text(item, "status"),
            "post_name" => namespaced_text(item, "post_name"),
            "post_date" => namespaced_text(item, "post_date"),
            "attachment_url" => namespaced_text(item, "attachment_url"),
            "creator" => text_at(item, "dc:creator", { "dc" => "http://purl.org/dc/elements/1.1/" }),
            "content" => text_at(item, "content:encoded", { "content" => "http://purl.org/rss/1.0/modules/content/" }),
            "excerpt" => text_at(item, "excerpt:encoded", { "excerpt" => "http://wordpress.org/export/1.2/excerpt/" }),
            "thumbnail_id" => thumbnail_id_for(item)
          }
        end
        rows
      end
    end

    def count_by
      counts = Hash.new(0)
      items.each do |item|
        key = yield(item).to_s
        counts[key] += 1
      end
      counts
    end

    def ledger_row_for(item)
      type = item.fetch("post_type")
      status = item.fetch("status")
      slug = item.fetch("post_name")
      date = parse_date(item.fetch("post_date"))

      {
        "legacy_id" => [type, item.fetch("post_id"), slug].reject(&:empty?).join("-"),
        "content_type" => content_type_for(type),
        "title" => item.fetch("title"),
        "legacy_status" => status,
        "source_priority" => "wordpress_export",
        "primary_source_type" => "wordpress_export",
        "primary_source_url" => item.fetch("link"),
        "wayback_url" => wayback_url_for(item.fetch("link")),
        "target_surface" => target_surface_for(type),
        "target_path" => target_path_for(type, slug, date),
        "content_status" => content_status_for(status),
        "media_status" => "unknown",
        "notes" => notes_for(type, status)
      }
    end

    def content_type_for(type)
      case type
      when "post" then "news"
      when "page" then "page"
      else type
      end
    end

    def target_surface_for(type)
      case type
      when "post" then "/news/"
      when "page" then ""
      else ""
      end
    end

    def target_path_for(type, slug, date)
      case type
      when "post"
        return "" if slug.to_s.empty? || date.nil?

        "_posts/#{date.strftime('%Y-%m-%d')}-#{slug}.md"
      else
        ""
      end
    end

    def content_status_for(status)
      case status
      when "publish" then "needs_import"
      when "draft", "private" then "needs_review"
      when "trash" then "needs_recovery"
      else "needs_review"
      end
    end

    def notes_for(type, status)
      notes = []
      notes << "Map this page to a current public route before import." if type == "page"
      notes << "Recover from Wayback only if the WordPress export content is incomplete." if status == "trash"
      notes.join(" ")
    end

    def wayback_url_for(url)
      return "" if url.to_s.empty?

      "https://web.archive.org/web/*/#{url}"
    end

    def parse_date(value)
      return nil if value.to_s.empty?

      Date.parse(value)
    rescue Date::Error
      nil
    end

    def thumbnail_id_for(item)
      item.elements.each do |meta|
        next unless meta.name == "postmeta" && meta.namespace == WP_NAMESPACE.fetch("wp")

        key = text_at(meta, "wp:meta_key", WP_NAMESPACE)
        next unless key == "_thumbnail_id"

        return text_at(meta, "wp:meta_value", WP_NAMESPACE)
      end

      ""
    end

    def namespaced_text(node, name)
      child_text(node, name, WP_NAMESPACE.fetch("wp"))
    end

    def text_at(node, xpath, namespaces = {})
      REXML::XPath.first(node, xpath, namespaces)&.text.to_s
    end

    def child_text(node, name, namespace = nil)
      element = node.elements.find do |child|
        child.name == name && child.namespace == namespace
      end
      element&.text.to_s
    end

    def ledger_headers
      %w[
        legacy_id
        content_type
        title
        legacy_status
        source_priority
        primary_source_type
        primary_source_url
        wayback_url
        target_surface
        target_path
        content_status
        media_status
        notes
      ]
    end
  end
end
