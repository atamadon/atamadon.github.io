#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/team_validator"

validator = LabSite::TeamValidator.new(root: Dir.pwd)
errors = validator.validate

if errors.empty?
  puts "Team entries are valid."
  exit 0
end

warn "Team validation failed:"
errors.each { |error| warn "  - #{error}" }
exit 1
