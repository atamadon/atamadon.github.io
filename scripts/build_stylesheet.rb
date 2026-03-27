#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("..", __dir__))
PARTS = %w[
  assets/css/site/_tokens.scss
  assets/css/site/_base.scss
  assets/css/site/_shell.scss
  assets/css/site/_hero.scss
  assets/css/site/_cards.scss
  assets/css/site/_team.scss
  assets/css/site/_publications.scss
  assets/css/site/_news.scss
  assets/css/site/_teaching.scss
  assets/css/site/_contact.scss
  assets/css/site/_embeds.scss
  assets/css/site/_responsive.scss
].freeze

output_path = ROOT.join("assets/css/style.css")
header = "/* Generated from assets/css/site/*.scss via scripts/build_stylesheet.rb. */\n\n"
body = PARTS.map { |relative_path| ROOT.join(relative_path).read }.join("\n\n")
output_path.write(header + body)
