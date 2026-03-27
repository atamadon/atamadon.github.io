#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "optparse"
require "fileutils"

require "lab_site/wordpress_export_inventory"
require "lab_site/wordpress_news_importer"

options = {
  write: false,
  overwrite: false,
  output_root: Dir.pwd
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/import_wordpress_news.rb path/to/export.xml [--write] [--overwrite]"

  opts.on("--write", "Write imported published posts into _posts/") do
    options[:write] = true
  end

  opts.on("--overwrite", "Overwrite existing _posts files when writing") do
    options[:overwrite] = true
  end
end

parser.parse!(ARGV)

input_path = ARGV.shift
abort(parser.to_s) unless input_path

inventory = LabSite::WordpressExportInventory.load_file(input_path)
importer = LabSite::WordpressNewsImporter.new(inventory)
records = importer.importable_posts

puts "Importable published WordPress posts: #{records.length}"
records.each do |record|
  puts "  - #{record[:relative_path]} | #{record[:title]}"
end

if options[:write]
  FileUtils.mkdir_p(File.join(options[:output_root], "_posts"))
  result = importer.write_posts(output_root: options[:output_root], overwrite: options[:overwrite])
  puts
  puts "Wrote #{result[:written].length} post(s)."
  if result[:skipped].any?
    puts "Skipped existing files:"
    result[:skipped].each { |path| puts "  - #{path}" }
  end
end
