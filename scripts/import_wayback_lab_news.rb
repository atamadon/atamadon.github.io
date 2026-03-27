#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "optparse"

require "lab_site/wayback_lab_news_importer"

options = {
  write: false
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/import_wayback_lab_news.rb PATH_TO_WAYBACK_HTML [--write]"

  opts.on("--write", "Write recovered Wayback lab news entries into _posts") do
    options[:write] = true
  end
end

parser.parse!(ARGV)

input_path = ARGV.shift or abort(parser.to_s)
html = File.read(input_path)
source_url = "https://web.archive.org/web/20150420032836/http://biomechanics.berkeley.edu:80/category/lab-news"

importer = LabSite::WaybackLabNewsImporter.new(root: Dir.pwd, html: html, source_url: source_url)

if options[:write]
  result = importer.write_posts
  puts "Recovered Wayback lab news entries written: #{result[:written].length}"
  result[:written].each { |path| puts "  - #{path}" }
  if result[:skipped].any?
    puts
    puts "Skipped existing paths: #{result[:skipped].length}"
    result[:skipped].each { |path| puts "  - #{path}" }
  end
else
  puts "Recoverable Wayback lab news entries: #{importer.entries.length}"
  importer.entries.each do |entry|
    puts "  - #{entry[:date_label]}: #{entry[:title]}"
  end
end
