#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "fileutils"

require "lab_site/team_onboarding_export"

def usage
  warn "Usage: ruby scripts/render_team_onboarding_export.rb path/to/approved-public-export.yml [--write]"
  exit 1
end

input_path = ARGV.find { |arg| !arg.start_with?("--") }
write_output = ARGV.include?("--write")

usage unless input_path

export = LabSite::TeamOnboardingExport.load_file(input_path)
rendered = export.render_team_entry

puts "Proposed team entry path: #{export.target_team_path || '(unresolved)'}"
puts "Proposed image asset path: #{export.proposed_image_asset_path || '(missing)'}"

warnings = export.warnings
if warnings.empty?
  puts "Warnings: none"
else
  puts "Warnings:"
  warnings.each { |warning| puts "  - #{warning}" }
end

if write_output
  target = export.target_team_path
  abort("Cannot write without a resolvable target team path") unless target

  output_path = File.join(Dir.pwd, target.sub(%r{\A/}, ""))
  FileUtils.mkdir_p(File.dirname(output_path))
  File.write(output_path, rendered)
  puts "Wrote team entry to #{output_path}"
else
  puts
  puts rendered
end
