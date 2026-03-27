require "cgi"
require "fileutils"
require "pathname"
require "time"
require "yaml"

require_relative "wordpress_export_inventory"

module LabSite
  class WordpressNewsImporter
    attr_reader :inventory

    def initialize(inventory)
      @inventory = inventory
    end

    def importable_posts
      inventory.published_posts.map { |post| build_import_record(post) }
    end

    def write_posts(output_root:, overwrite: false)
      records = importable_posts
      written = []
      skipped = []

      records.each do |record|
        output_path = File.join(output_root, record[:relative_path])
        if File.exist?(output_path) && !overwrite
          skipped << output_path
          next
        end

        FileUtils.mkdir_p(File.dirname(output_path))
        File.write(output_path, record[:rendered])
        written << output_path
      end

      { written: written, skipped: skipped, records: records }
    end

    private

    def build_import_record(post)
      slug = post.fetch("post_name")
      title = normalize_text(post.fetch("title"))
      published_at = Time.parse(post.fetch("post_date"))
      featured_image_url = inventory.attachments_by_id[post.fetch("thumbnail_id", "")]

      fields = {
        "layout" => "post",
        "title" => title,
        "date" => published_at.strftime("%Y-%m-%d %H:%M:%S"),
        "legacy_wordpress_post_id" => post.fetch("post_id"),
        "legacy_source_url" => post.fetch("link")
      }
      fields["legacy_featured_image_url"] = featured_image_url unless featured_image_url.to_s.empty?

      relative_path = "_posts/#{published_at.strftime('%Y-%m-%d')}-#{slug}.md"

      {
        slug: slug,
        title: title,
        date: published_at,
        relative_path: relative_path,
        featured_image_url: featured_image_url,
        rendered: render_post(fields, normalized_body(post.fetch("content")))
      }
    end

    def render_post(fields, body)
      front_matter = +"---\n"
      front_matter << YAML.dump(fields).sub(/\A---\s*\n/, "")
      front_matter << "---\n\n"
      front_matter << body.rstrip
      front_matter << "\n"
      front_matter
    end

    def normalized_body(content)
      body = content.to_s.dup
      body.gsub!(/<!--\s*wp:[^>]*-->\s*/m, "")
      body.gsub!(/<!--\s*\/wp:[^>]*-->\s*/m, "")
      body.gsub!(/\r\n?/, "\n")
      body.gsub!(/[ \t]+\n/, "\n")
      body.gsub!(/\n{3,}/, "\n\n")
      body = body.strip
      body = "<p>Legacy WordPress content could not be exported cleanly for this entry.</p>" if body.empty?
      body
    end

    def normalize_text(text)
      normalized = text.to_s.gsub(/&nbsp;|&#160;/i, " ")
      CGI.unescapeHTML(normalized).gsub(/\u00A0/, " ").strip
    end
  end
end
