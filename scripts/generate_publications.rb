#!/usr/bin/env ruby

require "optparse"
$stdout.sync = true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/publication_generator"

options = {
  live: true,
  use_legacy_only: false
}

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/generate_publications.rb [options]"

  parser.on("--use-legacy-only", "Generate publications from legacy _publications entries only") do
    options[:live] = false
    options[:use_legacy_only] = true
  end
end.parse!

def summarize_counts(records, key)
  records
    .each_with_object(Hash.new(0)) { |record, counts| counts[record[key].to_s] += 1 if record[key] }
    .sort_by { |name, count| [-count, name] }
    .map { |name, count| "#{count} #{name}" }
    .join(", ")
end

def date_range(records)
  dates = records.filter_map do |record|
    value = record["date"].to_s.strip
    value unless value.empty?
  end.sort
  return nil if dates.empty?

  "#{dates.first} to #{dates.last}"
end

def custom_image_count(records)
  records.count do |record|
    image_url = record["image_url"].to_s
    !image_url.empty? && !image_url.include?("publication-placeholder")
  end
end

mode_label = options[:use_legacy_only] ? "legacy seed only" : "live OpenAlex + legacy merge"
output_path = File.join(Dir.pwd, "_data/generated/publications.json")
start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

puts "Starting publication generation (#{mode_label})..."

generator = LabSite::PublicationGenerator.new(
  root: Dir.pwd,
  live: options[:live],
  use_legacy_only: options[:use_legacy_only],
  logger: ->(message) { puts "[publications] #{message}" }
)

records = generator.write
elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

puts "Wrote #{records.length} publication records to #{output_path}"
puts format("Completed in %.2fs", elapsed)
puts "Types: #{summarize_counts(records, 'type')}"
puts "Display types: #{summarize_counts(records, 'display_type')}"
puts "Sources: #{summarize_counts(records, 'source_provider')}"
puts "Image sources: #{summarize_counts(records, 'image_source')}"
puts "Featured: #{records.count { |record| record['featured'] }}"
puts "Custom images: #{custom_image_count(records)}"
puts "Cache: #{generator.stats.sort.map { |key, value| "#{key}=#{value}" }.join(', ')}" unless generator.stats.empty?

range = date_range(records)
puts "Date range: #{range}" if range
