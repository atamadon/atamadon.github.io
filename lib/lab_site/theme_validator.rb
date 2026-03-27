require "pathname"
require "yaml"

module LabSite
  class ThemeValidator
    REQUIRED_SITE_FIELDS = [
      %w[name],
      %w[brand logo],
      %w[header title label],
      %w[header title url],
      %w[contact email],
      %w[accessibility report_url],
      %w[accessibility support_email],
      %w[governance privacy_url],
      %w[governance nondiscrimination_url]
    ].freeze
    REQUIRED_THEME_FIELDS = [
      %w[layout content_width],
      %w[radius card],
      %w[radius pill],
      %w[shadows light_card],
      %w[shadows light_card_hover],
      %w[shadows dark_card],
      %w[shadows dark_card_hover],
      %w[motion enabled]
    ].freeze
    REQUIRED_COLOR_KEYS = %w[
      berkeley_blue
      berkeley_gold
      accent_blue
      accent_gold
      ink_900
      ink_700
      line_300
      surface_0
      surface_50
      surface_100
      surface_tint
      header_bg
      header_surface
      header_border
      header_text
      header_muted
      theme_toggle_ring
      body_gradient_top
      body_gradient_mid
    ].freeze
    COLOR_PATTERN = /\A(#(?:\h{3}|\h{6})|rgba?\([^)]+\)|hsla?\([^)]+\)|transparent|currentColor)\z/i
    LENGTH_PATTERN = /\A\d+(?:\.\d+)?(?:rem|px|em|ch|vw|vh|%)\z/
    EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
    URL_PATTERN = /\Ahttps?:\/\/\S+\z/i

    def initialize(root:)
      @root = Pathname.new(root)
      @site = load_yaml("_data/site.yml")
      @theme = load_yaml("_data/theme.yml")
    end

    def validate
      errors = []
      errors.concat(validate_site)
      errors.concat(validate_theme)
      errors
    end

    private

    def load_yaml(relative_path)
      path = @root.join(relative_path)
      YAML.safe_load(File.read(path), aliases: true) || {}
    end

    def validate_site
      errors = []

      REQUIRED_SITE_FIELDS.each do |path|
        value = dig(@site, path)
        errors << "_data/site.yml is missing required field `#{path.join('.')}`" if value.to_s.strip.empty?
      end

      errors << "_data/site.yml contact.email must be a valid email" unless dig(@site, %w[contact email]).to_s.match?(EMAIL_PATTERN)
      errors << "_data/site.yml accessibility.support_email must be a valid email" unless dig(@site, %w[accessibility support_email]).to_s.match?(EMAIL_PATTERN)

      [%w[accessibility report_url], %w[governance privacy_url], %w[governance nondiscrimination_url]].each do |path|
        value = dig(@site, path).to_s
        errors << "_data/site.yml #{path.join('.')} must be an absolute URL" unless value.match?(URL_PATTERN)
      end

      title_url = dig(@site, %w[header title url]).to_s
      unless title_url.match?(link_pattern)
        errors << "_data/site.yml header.title.url must be a relative path or absolute URL"
      end

      subtitles = dig(@site, %w[header subtitles])
      unless subtitles.is_a?(Array)
        errors << "_data/site.yml header.subtitles must be a list"
        return errors
      end

      subtitles.each_with_index do |subtitle, index|
        unless subtitle.is_a?(Hash)
          errors << "_data/site.yml header.subtitles[#{index}] must be an object"
          next
        end

        label = subtitle["label"].to_s.strip
        url = subtitle["url"].to_s.strip

        errors << "_data/site.yml header.subtitles[#{index}].label is required" if label.empty?
        errors << "_data/site.yml header.subtitles[#{index}].url must be a relative path or absolute URL" unless url.match?(link_pattern)
      end

      logo = dig(@site, %w[brand logo]).to_s
      if !logo.empty? && !logo.start_with?("http://", "https://")
        local_path = @root.join(logo.sub(%r{\A/}, ""))
        errors << "_data/site.yml brand.logo references missing file #{logo}" unless local_path.exist?
      end

      errors
    end

    def validate_theme
      errors = []

      REQUIRED_THEME_FIELDS.each do |path|
        value = dig(@theme, path)
        errors << "_data/theme.yml is missing required field `#{path.join('.')}`" if value.nil? || value == ""
      end

      errors << "_data/theme.yml layout.content_width must be a CSS length" unless dig(@theme, %w[layout content_width]).to_s.match?(LENGTH_PATTERN)
      errors << "_data/theme.yml radius.card must be a CSS length" unless dig(@theme, %w[radius card]).to_s.match?(LENGTH_PATTERN)
      errors << "_data/theme.yml radius.pill must be a CSS length" unless dig(@theme, %w[radius pill]).to_s.match?(LENGTH_PATTERN)

      motion_enabled = dig(@theme, %w[motion enabled])
      errors << "_data/theme.yml motion.enabled must be true or false" unless [true, false].include?(motion_enabled)

      %w[light dark].each do |mode|
        REQUIRED_COLOR_KEYS.each do |key|
          value = dig(@theme, ["colors", mode, key]).to_s
          if value.empty?
            errors << "_data/theme.yml colors.#{mode}.#{key} is required"
            next
          end

          unless value.match?(COLOR_PATTERN)
            errors << "_data/theme.yml colors.#{mode}.#{key} must be a CSS color value"
          end
        end
      end

      errors
    end

    def dig(source, path)
      path.reduce(source) do |memo, key|
        memo.is_a?(Hash) ? memo[key] : nil
      end
    end

    def link_pattern
      /\A(?:\/.*|https?:\/\/\S+)\z/i
    end
  end
end
