require "cgi"
require "fileutils"
require "open-uri"
require "pathname"
require "uri"
require "yaml"

require_relative "front_matter"

module LabSite
  class WordpressNewsMediaLocalizer
    LEGACY_UPLOAD_PATTERN = %r{https://biomechanics\.berkeley\.edu/wp-content/uploads/[^\s"'()<>]+}

    def initialize(root:, downloader: nil)
      @root = root
      @downloader = downloader || method(:default_downloader)
    end

    def legacy_post_paths
      posts_dir = File.join(@root, "_posts")
      return [] unless Dir.exist?(posts_dir)

      Dir.children(posts_dir).select { |name| name.end_with?(".md") }.map { |name| File.join(posts_dir, name) }.select do |path|
        front_matter, = LabSite::FrontMatter.parse_file(path)
        front_matter.key?("legacy_source_url") || front_matter.key?("legacy_featured_image_url")
      end.sort
    end

    def plan_for(path)
      front_matter, content = LabSite::FrontMatter.parse_file(path)
      urls = referenced_legacy_urls(front_matter, content)
      slug = post_slug_from_path(path)
      assets = {}

      urls.each_with_index do |url, index|
        asset_rel = asset_relative_path(slug, index + 1, url)
        assets[url] = {
          relative_path: asset_rel,
          absolute_path: File.join(@root, asset_rel),
          featured: front_matter["legacy_featured_image_url"].to_s == url
        }
      end

      {
        post_path: path,
        slug: slug,
        front_matter: front_matter,
        content: content,
        assets: assets
      }
    end

    def localize(path, write: false)
      plan = plan_for(path)
      updated_front_matter = plan[:front_matter].dup
      updated_content = plan[:content].dup
      localized_assets = plan[:assets]
      failed_assets = {}

      if write
        localized_assets = {}

        plan[:assets].each do |legacy_url, asset|
          begin
            FileUtils.mkdir_p(File.dirname(asset[:absolute_path]))
            @downloader.call(legacy_url, asset[:absolute_path]) unless File.exist?(asset[:absolute_path])
            localized_assets[legacy_url] = asset
          rescue StandardError => e
            failed_assets[legacy_url] = {
              asset: asset,
              error: "#{e.class}: #{e.message}"
            }
          end
        end
      end

      localized_assets.each do |legacy_url, asset|
        updated_content = updated_content.gsub(legacy_url, relative_url(asset[:relative_path]))
      end

      featured_asset = localized_assets.values.find { |asset| asset[:featured] }
      if featured_asset
        updated_front_matter["featured_image"] = relative_url(featured_asset[:relative_path])
        updated_front_matter["featured_image_alt"] = updated_front_matter["featured_image_alt"].to_s.strip
        if updated_front_matter["featured_image_alt"].empty?
          updated_front_matter["featured_image_alt"] = updated_front_matter["title"].to_s
        end
      end

      rendered = render_post(updated_front_matter, updated_content)

      if write
        File.write(path, rendered)
      end

      plan.merge(
        updated_front_matter: updated_front_matter,
        updated_content: updated_content,
        rendered: rendered,
        localized_assets: localized_assets,
        failed_assets: failed_assets
      )
    end

    private

    def referenced_legacy_urls(front_matter, content)
      urls = []
      featured = front_matter["legacy_featured_image_url"].to_s.strip
      urls << featured unless featured.empty?
      urls.concat(content.to_s.scan(LEGACY_UPLOAD_PATTERN))
      urls.uniq
    end

    def post_slug_from_path(path)
      basename = File.basename(path, ".md")
      parts = basename.split("-", 4)
      parts.length == 4 ? parts.last : basename
    end

    def asset_relative_path(slug, index, url)
      extension = File.extname(url_path(url)).downcase
      extension = ".jpg" if extension.empty?
      File.join("assets", "images", "news", slug, format("%02d%s", index, extension))
    end

    def relative_url(path)
      "/" + path.tr("\\", "/").sub(%r{\A/}, "")
    end

    def url_path(url)
      escaped = URI::DEFAULT_PARSER.escape(url)
      URI.parse(escaped).path
    rescue URI::InvalidURIError
      URI.parse(URI::DEFAULT_PARSER.escape(url.encode("UTF-8", invalid: :replace, undef: :replace))).path
    end

    def default_downloader(url, destination)
      escaped = URI::DEFAULT_PARSER.escape(url)
      URI.open(escaped, "rb") do |remote|
        File.binwrite(destination, remote.read)
      end
    end

    def render_post(front_matter, content)
      +"---\n" +
        YAML.dump(front_matter).sub(/\A---\s*\n/, "") +
        "---\n\n" +
        content.rstrip +
        "\n"
    end
  end
end
