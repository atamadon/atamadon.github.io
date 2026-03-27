#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "optparse"
require "pathname"

require "lab_site/wordpress_export_inventory"

options = {
  ledger_out: nil
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/inventory_wordpress_export.rb path/to/export.xml [--ledger-out path/to/ledger.csv]"

  opts.on("--ledger-out PATH", "Write a draft migration ledger CSV for WordPress posts and pages") do |path|
    options[:ledger_out] = path
  end
end

parser.parse!(ARGV)

input_path = ARGV.shift
abort(parser.to_s) unless input_path

inventory = LabSite::WordpressExportInventory.load_file(input_path)

puts "Site title: #{inventory.site_title}"
puts "Site link: #{inventory.site_link}"
puts "Source export: #{Pathname.new(input_path).basename}"
puts "Items: #{inventory.item_count}"
puts

puts "Post types:"
inventory.type_counts.sort_by { |type, count| [-count, type] }.each do |type, count|
  puts "  - #{type}: #{count}"
end
puts

puts "Statuses:"
inventory.status_counts.sort_by { |status, count| [-count, status] }.each do |status, count|
  puts "  - #{status}: #{count}"
end
puts

puts "Published posts:"
if inventory.published_posts.empty?
  puts "  - none"
else
  inventory.published_posts.each do |item|
    puts "  - #{item['post_date']} | #{item['post_name']} | #{item['title']}"
  end
end
puts

puts "Published pages:"
if inventory.published_pages.empty?
  puts "  - none"
else
  inventory.published_pages.each do |item|
    puts "  - #{item['post_date']} | #{item['post_name']} | #{item['title']}"
  end
end

if options[:ledger_out]
  output_path = File.expand_path(options[:ledger_out], Dir.pwd)
  inventory.write_ledger_csv(output_path)
  puts
  puts "Wrote draft migration ledger to #{output_path}"
end
