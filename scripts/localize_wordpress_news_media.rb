#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "optparse"

require "lab_site/wordpress_news_media_localizer"

options = {
  write: false
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby scripts/localize_wordpress_news_media.rb [--write]"

  opts.on("--write", "Download legacy WordPress media and rewrite imported news posts to local asset paths") do
    options[:write] = true
  end
end

parser.parse!(ARGV)

localizer = LabSite::WordpressNewsMediaLocalizer.new(root: Dir.pwd)
plans = localizer.legacy_post_paths.map { |path| localizer.localize(path, write: options[:write]) }

puts "Legacy WordPress news posts with media references: #{plans.length}"
plans.each do |plan|
  localized_count = plan.fetch(:localized_assets, plan[:assets]).length
  failed_count = plan.fetch(:failed_assets, {}).length
  summary = "  - #{File.basename(plan[:post_path])}: #{localized_count} localized"
  summary += ", #{failed_count} missing" if failed_count.positive?
  puts summary
end

if options[:write]
  puts
  puts "Localized media into assets/images/news/ and rewrote imported post bodies/front matter."
  missing_assets = plans.sum { |plan| plan.fetch(:failed_assets, {}).length }

  if missing_assets.positive?
    puts
    puts "Missing legacy assets left on original URLs for later recovery: #{missing_assets}"
    plans.each do |plan|
      plan.fetch(:failed_assets, {}).each do |legacy_url, failure|
        puts "  - #{File.basename(plan[:post_path])}: #{legacy_url}"
        puts "    #{failure[:error]}"
      end
    end
  end
end
