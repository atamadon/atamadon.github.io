require "pathname"
require "yaml"
require "date"

module LabSite
  class TeamOnboardingExport
    REQUIRED_PUBLIC_FIELDS = %w[
      berkeley_username
      name
      role
      status
      groups
      email
      image
      active
      sort_order
    ].freeze

    OPTIONAL_PUBLIC_FIELDS = %w[
      bio_short
      body
      show_email
      website
      scholar
      orcid
      linkedin
      github
      placeholder
    ].freeze

    ROLE_DIRECTORIES = {
      "Principal Investigator" => "pi",
      "Postdoc" => "postdoc",
      "Graduate Student" => "grad",
      "Undergraduate Student" => "ugrad",
      "Alumni" => "alumni"
    }.freeze

    ALLOWED_GROUPS = %w[molecular-dynamics ai microbiome].freeze
    URL_FIELDS = %w[website scholar orcid linkedin github].freeze
    URL_PATTERN = /\Ahttps?:\/\/[^\s]+\z/
    USERNAME_PATTERN = /\A[a-z0-9][a-z0-9-]*\z/
    EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

    attr_reader :data

    def self.load_file(path)
      raw = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
      new(raw)
    end

    def initialize(data)
      @data = data
    end

    def public_profile
      profile = data["public_profile"]
      profile.is_a?(Hash) ? profile : {}
    end

    def warnings
      messages = []

      REQUIRED_PUBLIC_FIELDS.each do |field|
        value = public_profile[field]
        messages << "Missing required public field `#{field}`" if value.nil? || value == "" || value == []
      end

      username = public_profile["berkeley_username"].to_s
      messages << "Public `berkeley_username` must use lowercase kebab-case" unless username.empty? || username.match?(USERNAME_PATTERN)

      email = public_profile["email"].to_s
      messages << "Public `email` must be a valid email address" unless email.empty? || email.match?(EMAIL_PATTERN)

      groups = public_profile["groups"]
      if !groups.nil? && !groups.is_a?(Array)
        messages << "Public `groups` must be a list"
      elsif groups.is_a?(Array)
        groups.each do |group|
          next if ALLOWED_GROUPS.include?(group.to_s)

          messages << "Unknown public group `#{group}`"
        end
      end

      active = public_profile["active"]
      messages << "Public `active` must be true or false" unless active.nil? || [true, false].include?(active)

      sort_order = public_profile["sort_order"]
      messages << "Public `sort_order` must be numeric" unless sort_order.nil? || sort_order.is_a?(Integer)

      show_email = public_profile["show_email"]
      messages << "Public `show_email` must be true or false" unless show_email.nil? || [true, false].include?(show_email)

      placeholder = public_profile["placeholder"]
      messages << "Public `placeholder` must be true or false" unless placeholder.nil? || [true, false].include?(placeholder)

      URL_FIELDS.each do |field|
        value = public_profile[field].to_s
        next if value.empty? || value.match?(URL_PATTERN)

        messages << "Public `#{field}` must start with http:// or https://"
      end

      messages << "Unrecognized role `#{public_profile['role']}` for team directory mapping" if target_team_path.nil?
      messages << "Public export is opting out of website listing (`active: false`)" if public_profile["active"] == false
      messages << "Public export uses a placeholder image" if proposed_image_asset_path&.end_with?("profile-placeholder.svg")

      messages.uniq
    end

    def target_team_path
      role_dir = ROLE_DIRECTORIES[public_profile["role"]]
      username = public_profile["berkeley_username"].to_s
      return nil if role_dir.nil? || username.empty?

      "/_team/#{role_dir}/#{username}.md"
    end

    def proposed_image_asset_path
      image = public_profile["image"].to_s
      return nil if image.empty?

      image
    end

    def render_team_entry
      fields = {}

      REQUIRED_PUBLIC_FIELDS.each do |field|
        value = public_profile[field]
        fields[field] = value unless value.nil?
      end

      OPTIONAL_PUBLIC_FIELDS.each do |field|
        value = public_profile[field]
        next if value.nil? || value == ""

        fields[field] = value
      end

      body = fields.delete("body").to_s

      front_matter = +"---\n"
      front_matter << yaml_fragment(fields)
      front_matter << "---\n"
      front_matter << body.rstrip
      front_matter << "\n" unless body.empty?
      front_matter
    end

    private

    def yaml_fragment(object)
      YAML.dump(object).sub(/\A---\s*\n/, "")
    end
  end
end
