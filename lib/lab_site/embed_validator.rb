require "pathname"
require "yaml"

require_relative "front_matter"

module LabSite
  class EmbedValidator
    CONTENT_GLOBS = [
      "*.md",
      "contact/**/*.md",
      "news/**/*.md",
      "publications/**/*.md",
      "research/**/*.md",
      "teaching/**/*.md",
      "team/**/*.md",
      "_posts/**/*.md"
    ].freeze
    VALID_TYPES = %w[molstar video document map].freeze

    def initialize(root:)
      @root = Pathname.new(root)
      structures_path = @root.join("_data/structures.yml")
      @structures = YAML.safe_load(File.read(structures_path), aliases: true) || {}
    end

    def validate
      errors = []

      content_files.each do |path|
        front_matter, = LabSite::FrontMatter.parse_file(path)
        embeds = front_matter["embeds"]
        next if embeds.nil?

        unless embeds.is_a?(Array)
          errors << "#{relative(path)} must define `embeds` as a list"
          next
        end

        embeds.each_with_index do |embed, index|
          errors.concat(validate_embed(path, embed, index))
        end
      end

      errors
    end

    private

    def content_files
      CONTENT_GLOBS.flat_map { |pattern| Dir.glob(@root.join(pattern)) }.uniq.sort
    end

    def validate_embed(path, embed, index)
      errors = []

      unless embed.is_a?(Hash)
        errors << "#{relative(path)} embed ##{index + 1} must be an object"
        return errors
      end

      type = embed["type"] || embed["_block"]
      unless VALID_TYPES.include?(type)
        errors << "#{relative(path)} embed ##{index + 1} has unsupported type `#{type}`"
        return errors
      end

      case type
      when "molstar"
        structure_id = embed["structure_id"].to_s
        if structure_id.empty?
          errors << "#{relative(path)} embed ##{index + 1} must set `structure_id` for a Mol* block"
        elsif !@structures.key?(structure_id)
          errors << "#{relative(path)} embed ##{index + 1} references unknown structure `#{structure_id}`"
        end
      when "video", "map"
        errors << "#{relative(path)} embed ##{index + 1} must set `embed_url` for a #{type} block" if embed["embed_url"].to_s.strip.empty?
      when "document"
        file = embed["file"].to_s.strip
        url = embed["url"].to_s.strip
        preview_url = embed["preview_url"].to_s.strip
        if file.empty? && url.empty?
          errors << "#{relative(path)} embed ##{index + 1} must set either `file` or `url` for a document block"
        end

        errors.concat(validate_local_asset(path, file, index, "file")) unless file.empty?
        errors.concat(validate_local_asset(path, preview_url, index, "preview_url")) unless preview_url.empty?
      end

      errors
    end

    def validate_local_asset(path, value, index, field)
      return [] if value.include?("://")

      local_path = @root.join(value.sub(%r{\A/}, ""))
      return [] if local_path.exist?

      ["#{relative(path)} embed ##{index + 1} references missing local #{field} #{value}"]
    end

    def relative(path)
      Pathname.new(path).relative_path_from(@root).to_s
    end
  end
end
