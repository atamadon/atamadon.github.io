#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/embed_validator"

validator = LabSite::EmbedValidator.new(root: Dir.pwd)
errors = validator.validate

if errors.empty?
  puts "Embed blocks are valid."
  exit 0
end

warn "Embed validation failed:"
errors.each { |error| warn "  - #{error}" }
exit 1
