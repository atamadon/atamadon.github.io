require "yaml"
require "date"

module LabSite
  module FrontMatter
    module_function

    FRONT_MATTER_PATTERN = /\A---\s*\n(.*?)\n---\s*\n?/m

    def parse_file(path)
      raw = File.read(path)
      match = FRONT_MATTER_PATTERN.match(raw)

      return [{}, raw] unless match

      data = YAML.safe_load(
        match[1],
        permitted_classes: [Date, Time],
        aliases: true
      ) || {}

      content = raw[match.end(0)..] || ""
      [data, content]
    end
  end
end
