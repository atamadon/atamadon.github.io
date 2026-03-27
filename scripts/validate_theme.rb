#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/theme_validator"

validator = LabSite::ThemeValidator.new(root: Dir.pwd)
errors = validator.validate

if errors.empty?
  puts "Theme and site settings are valid."
  exit 0
end

warn "Theme and site settings validation failed:"
errors.each { |error| warn "  - #{error}" }
exit 1
