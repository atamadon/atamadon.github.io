require "pathname"

require_relative "front_matter"

module LabSite
  class TeamValidator
    REQUIRED_FIELDS = %w[berkeley_username name role status groups email image active sort_order].freeze
    EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
    USERNAME_PATTERN = /\A[a-z0-9][a-z0-9-]*\z/
    ALLOWED_GROUPS = %w[molecular-dynamics ai microbiome].freeze

    def initialize(root:)
      @root = Pathname.new(root)
    end

    def validate
      errors = []
      seen_usernames = {}

      team_files.each do |path|
        front_matter, content = LabSite::FrontMatter.parse_file(path)
        errors.concat(validate_required_fields(path, front_matter))
        errors.concat(validate_types(path, front_matter))
        errors.concat(validate_filename(path, front_matter))
        errors.concat(validate_identity(path, front_matter, seen_usernames))
        errors.concat(validate_active_image(path, front_matter))
        errors.concat(validate_bio(path, front_matter, content))
      end

      errors
    end

    private

    def team_files
      Dir.glob(@root.join("_team", "**", "*.md")).sort
    end

    def validate_required_fields(path, front_matter)
      REQUIRED_FIELDS.filter_map do |field|
        value = front_matter[field]
        next unless value.nil? || value == ""

        "#{relative(path)} is missing required field `#{field}`"
      end
    end

    def validate_types(path, front_matter)
      errors = []
      errors << "#{relative(path)} has invalid email `#{front_matter['email']}`" unless front_matter["email"].to_s.match?(EMAIL_PATTERN)
      errors << "#{relative(path)} must use a lowercase kebab-case `berkeley_username`" unless front_matter["berkeley_username"].to_s.match?(USERNAME_PATTERN)
      errors << "#{relative(path)} must set `active` to true or false" unless [true, false].include?(front_matter["active"])
      errors << "#{relative(path)} must set numeric `sort_order`" unless front_matter["sort_order"].is_a?(Integer)
      errors.concat(validate_groups(path, front_matter))
      errors
    end

    def validate_groups(path, front_matter)
      groups = front_matter["groups"]
      return ["#{relative(path)} `groups` must be a list"] unless groups.is_a?(Array)
      return ["#{relative(path)} `groups` must not be empty"] if groups.empty?

      groups.filter_map do |g|
        next if ALLOWED_GROUPS.include?(g.to_s)

        "#{relative(path)} has unknown group `#{g}` (allowed: #{ALLOWED_GROUPS.join(', ')})"
      end
    end

    def validate_filename(path, front_matter)
      base = File.basename(path, ".md")
      expected = front_matter["berkeley_username"].to_s
      return [] if expected.empty? || base == expected

      ["#{relative(path)} filename must match berkeley_username `#{expected}`"]
    end

    def validate_identity(path, front_matter, seen_usernames)
      username = front_matter["berkeley_username"].to_s
      return [] if username.empty?

      previous = seen_usernames[username]
      seen_usernames[username] = relative(path)
      return [] unless previous

      ["Duplicate berkeley_username `#{username}` in #{previous} and #{relative(path)}"]
    end

    def validate_active_image(path, front_matter)
      return [] unless front_matter["active"]

      image = front_matter["image"].to_s
      return [] if image.start_with?("http://", "https://")

      local_path = @root.join(image.sub(%r{\A/}, ""))
      return [] if local_path.exist?

      ["#{relative(path)} references missing image #{image}"]
    end

    def validate_bio(path, front_matter, content)
      return [] unless front_matter["active"]
      return [] unless front_matter["bio_short"].to_s.strip.empty? && content.to_s.strip.empty?

      ["#{relative(path)} should include either `bio_short` or body content for active members"]
    end

    def relative(path)
      Pathname.new(path).relative_path_from(@root).to_s
    end
  end
end
