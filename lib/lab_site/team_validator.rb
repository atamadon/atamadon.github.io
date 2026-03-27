require "pathname"
require "find"

require_relative "front_matter"

module LabSite
  class TeamValidator
    REQUIRED_FIELDS = %w[berkeley_username name role status active].freeze
    EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
    USERNAME_PATTERN = /\A[a-z0-9][a-z0-9-]*\z/
    URL_PATTERN = /\Ahttps?:\/\/[^\s]+\z/
    DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/
    ALLOWED_GROUPS = %w[molecular-dynamics ai microbiome].freeze
    URL_FIELDS = %w[website scholar orcid linkedin github].freeze

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
      end

      errors
    end

    private

    def team_files
      root = @root.join("_team")
      return [] unless root.exist?

      files = []
      Find.find(root.to_s) do |path|
        files << path if File.file?(path) && File.extname(path) == ".md"
      end
      files.sort
    end

    def validate_required_fields(path, front_matter)
      errors = REQUIRED_FIELDS.filter_map do |field|
        value = front_matter[field]
        next unless value.nil? || value == ""

        "#{relative(path)} is missing required field `#{field}`"
      end

      if front_matter["active"]
        %w[groups email image join_date].each do |field|
          value = front_matter[field]
          next unless value.nil? || value == ""

          errors << "#{relative(path)} is missing required field `#{field}`"
        end
      else
        value = front_matter["leave_date"]
        errors << "#{relative(path)} is missing required field `leave_date`" if value.nil? || value == ""
      end

      if front_matter["show_email"]
        value = front_matter["email"]
        errors << "#{relative(path)} is missing required field `email`" if value.nil? || value == ""
      end

      errors
    end

    def validate_types(path, front_matter)
      errors = []
      if !front_matter["email"].to_s.empty? && !front_matter["email"].to_s.match?(EMAIL_PATTERN)
        errors << "#{relative(path)} has invalid email `#{front_matter['email']}`"
      end
      errors << "#{relative(path)} must use a lowercase kebab-case `berkeley_username`" unless front_matter["berkeley_username"].to_s.match?(USERNAME_PATTERN)
      errors << "#{relative(path)} must set `active` to true or false" unless [true, false].include?(front_matter["active"])
      if front_matter.key?("sort_order") && !front_matter["sort_order"].is_a?(Integer)
        errors << "#{relative(path)} must set numeric `sort_order` when present"
      end
      %w[join_date leave_date].each do |field|
        next if front_matter[field].nil? || front_matter[field] == ""
        next if valid_date?(front_matter[field])

        errors << "#{relative(path)} has invalid `#{field}`; use YYYY-MM-DD"
      end
      errors << "#{relative(path)} must set `show_email` to true or false when present" if front_matter.key?("show_email") && ![true, false].include?(front_matter["show_email"])
      URL_FIELDS.each do |field|
        next if front_matter[field].to_s.empty? || front_matter[field].to_s.match?(URL_PATTERN)

        errors << "#{relative(path)} has invalid URL in `#{field}`"
      end
      errors.concat(validate_groups(path, front_matter))
      errors
    end

    def validate_groups(path, front_matter)
      groups = front_matter["groups"]
      return [] if (groups.nil? || groups == "") && !front_matter["active"]
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

    def valid_date?(value)
      return true if value.is_a?(Date) || value.is_a?(Time)
      return false unless value.to_s.match?(DATE_PATTERN)

      Date.iso8601(value.to_s)
      true
    rescue Date::Error
      false
    end

    def relative(path)
      Pathname.new(path).relative_path_from(@root).to_s
    end
  end
end
