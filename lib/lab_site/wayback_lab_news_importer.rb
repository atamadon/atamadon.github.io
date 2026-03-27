require "cgi"
require "date"
require "fileutils"
require "set"
require "yaml"

require_relative "front_matter"

module LabSite
  class WaybackLabNewsImporter
    ENTRY_PATTERN = %r{<h4>(.*?)</h4>\s*<p>(.*?)</p>}mi
    DATE_FORMATS = [
      "%b %e, %Y",
      "%B %e, %Y",
      "%b %Y",
      "%B %Y"
    ].freeze

    def initialize(root:, html:, source_url:)
      @root = root
      @html = html
      @source_url = source_url
    end

    def entries
      @entries ||= parse_entries
    end

    def write_posts(overwrite: false)
      written = []
      skipped = []

      entries.each do |entry|
        output_path = File.join(@root, entry[:relative_path])
        if File.exist?(output_path) && !overwrite
          skipped << output_path
          next
        end

        FileUtils.mkdir_p(File.dirname(output_path))
        File.write(output_path, entry[:rendered])
        written << output_path
      end

      { written: written, skipped: skipped, entries: entries }
    end

    private

    def parse_entries
      existing_titles = existing_post_titles
      seen_titles = Set.new
      seen_paths = Set.new
      counts_by_date = Hash.new(0)

      @html.scan(ENTRY_PATTERN).filter_map do |raw_date, raw_body|
        date_label = normalize_text(raw_date)
        body_text = normalize_text(raw_body)
        next if date_label.empty? || body_text.empty?

        title = derive_title(body_text)
        next if title.empty?
        next if existing_titles.include?(title.downcase)
        next if seen_titles.include?(title.downcase)

        published_on = parse_date(date_label, counts_by_date)
        slug = slugify(title)
        relative_path = "_posts/#{published_on.strftime('%Y-%m-%d')}-#{slug}.md"
        while seen_paths.include?(relative_path)
          counts_by_date[published_on] += 1
          adjusted_date = published_on + counts_by_date[published_on]
          relative_path = "_posts/#{adjusted_date.strftime('%Y-%m-%d')}-#{slug}.md"
        end

        seen_titles << title.downcase
        seen_paths << relative_path

        fields = {
          "layout" => "post",
          "title" => title,
          "date" => "#{published_on.strftime('%Y-%m-%d')} 00:00:00",
          "legacy_source_url" => @source_url,
          "legacy_wayback_recovered" => true,
          "legacy_wayback_date_label" => date_label
        }

        {
          title: title,
          body: body_text,
          date_label: date_label,
          relative_path: relative_path,
          rendered: render_post(fields, body_text)
        }
      end
    end

    def render_post(fields, body_text)
      +"---\n" +
        YAML.dump(fields).sub(/\A---\s*\n/, "") +
        "---\n\n" +
        "<p>#{CGI.escapeHTML(body_text)}</p>\n"
    end

    def existing_post_titles
      posts_dir = File.join(@root, "_posts")
      return Set.new unless Dir.exist?(posts_dir)

      Dir.children(posts_dir).filter_map do |name|
        next unless name.end_with?(".md")

        front_matter, = LabSite::FrontMatter.parse_file(File.join(posts_dir, name))
        title = front_matter["title"].to_s.strip
        next if title.empty?

        title.downcase
      end.to_set
    end

    def normalize_text(text)
      CGI.unescapeHTML(text.to_s)
        .gsub(/<[^>]+>/, " ")
        .gsub(/\u00A0/, " ")
        .gsub(/\s+/, " ")
        .strip
    end

    def derive_title(body_text)
      title = body_text.dup
      title = title.sub(/\s+Congratulations,?\s+.*\z/i, "")
      title = title.sub(/\s+Enormous thanks.*\z/i, "")
      title.strip
    end

    def parse_date(label, counts_by_date)
      parsed = DATE_FORMATS.lazy.map do |format|
        begin
          Date.strptime(label, format)
        rescue ArgumentError
          nil
        end
      end.find(&:itself)

      raise ArgumentError, "Unrecognized Wayback lab news date label: #{label}" unless parsed

      date = parsed
      counts_by_date[date] += 1
      date + (counts_by_date[date] - 1)
    end

    def slugify(text)
      normalized = text.unicode_normalize(:nfkd).encode("ASCII", replace: "")
      slug = normalized.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
      slug = slug[0, 80].to_s.gsub(/-+\z/, "")
      slug.empty? ? "recovered-wayback-news" : slug
    end
  end
end
