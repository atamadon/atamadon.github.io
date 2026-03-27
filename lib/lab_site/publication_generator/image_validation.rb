module LabSite
  class PublicationGenerator
    module ImageValidation
      private

      def validate_image_candidate(candidate)
        return nil unless candidate && candidate[:url]

        image_url = candidate[:url].to_s
        cached = @cache.dig("validated_images", image_url)
        if cached
          @stats["validated_image_cache_hits"] += 1
          return cached["accepted"] ? candidate.merge(validation_metadata_from_cache(cached)) : nil
        end

        @stats["validated_image_cache_misses"] += 1
        validation = compute_image_validation(image_url)
        store_cache_entry("validated_images", image_url, validation)
        validation["accepted"] ? candidate.merge(validation_metadata_from_cache(validation)) : nil
      end

      def compute_image_validation(image_url)
        if junk_image_url?(image_url)
          return rejected_image_validation("junk_url")
        end

        uri = URI(image_url)
        response = fetch_response_with_headers(
          uri,
          redirects_remaining: MAX_REDIRECTS,
          headers: { "Range" => "bytes=0-#{IMAGE_METADATA_BYTES - 1}" }
        )
        return rejected_image_validation("fetch_failed") unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPPartialContent)

        content_type = response["content-type"].to_s.split(";").first.to_s.downcase
        return rejected_image_validation("not_image", content_type: content_type) unless content_type.start_with?("image/")

        body = response.body.to_s.b
        width, height = image_dimensions_from_binary(body, content_type)
        if width && height && width < 80 && height < 80
          return rejected_image_validation("too_small", content_type: content_type, width: width, height: height)
        end

        {
          "accepted" => true,
          "reason" => "ok",
          "content_type" => content_type,
          "width" => width,
          "height" => height,
          "content_length" => response["content-length"]&.to_i,
          "checked_at" => Time.now.utc.iso8601
        }
      rescue StandardError => error
        rejected_image_validation("validation_error", error: "#{error.class}: #{error.message}")
      end

      def rejected_image_validation(reason, extra = {})
        {
          "accepted" => false,
          "reason" => reason,
          "checked_at" => Time.now.utc.iso8601
        }.merge(extra)
      end

      def junk_image_url?(image_url)
        JUNK_IMAGE_PATTERNS.any? { |pattern| image_url.match?(pattern) }
      end

      def image_dimensions_from_binary(body, content_type)
        return png_dimensions(body) if content_type.include?("png")
        return gif_dimensions(body) if content_type.include?("gif")
        return jpeg_dimensions(body) if content_type.include?("jpeg") || content_type.include?("jpg")

        [nil, nil]
      end

      def png_dimensions(body)
        return [nil, nil] unless body.bytesize >= 24 && body.start_with?("\x89PNG".b)

        [body[16, 4].unpack1("N"), body[20, 4].unpack1("N")]
      end

      def gif_dimensions(body)
        return [nil, nil] unless body.bytesize >= 10 && body.start_with?("GIF".b)

        body[6, 4].unpack("vv")
      end

      def jpeg_dimensions(body)
        return [nil, nil] unless body.bytesize >= 4 && body.getbyte(0) == 0xFF && body.getbyte(1) == 0xD8

        index = 2
        while index + 9 < body.bytesize
          index += 1 while index < body.bytesize && body.getbyte(index) != 0xFF
          break if index + 9 >= body.bytesize

          marker = body.getbyte(index + 1)
          index += 2
          next if marker == 0xD8 || marker == 0xD9

          length = body[index, 2]&.unpack1("n")
          break unless length && length >= 2 && index + length <= body.bytesize

          if (0xC0..0xC3).cover?(marker) || (0xC5..0xC7).cover?(marker) || (0xC9..0xCB).cover?(marker) || (0xCD..0xCF).cover?(marker)
            height, width = body[index + 3, 4].unpack("nn")
            return [width, height]
          end

          index += length
        end

        [nil, nil]
      end

      def validation_metadata_from_cache(validation)
        {
          width: validation["width"],
          height: validation["height"],
          content_type: validation["content_type"]
        }.compact
      end

      def load_cache
        return default_cache unless File.exist?(@cache_path)

        parsed = JSON.parse(File.read(@cache_path))
        return default_cache unless parsed["version"] == CACHE_VERSION

        default_cache.merge(parsed)
      rescue StandardError
        default_cache
      end

      def default_cache
        {
          "version" => CACHE_VERSION,
          "resolved_images" => {},
          "validated_images" => {}
        }
      end

      def write_cache
        return unless @cache_dirty

        FileUtils.mkdir_p(File.dirname(@cache_path))
        temp_path = "#{@cache_path}.tmp"
        File.write(temp_path, JSON.pretty_generate(@cache) + "\n")
        FileUtils.mv(temp_path, @cache_path)
        @cache_dirty = false
      end

      def store_cache_entry(namespace, key, value)
        @cache[namespace][key] = value
        @cache_dirty = true
      end

      def symbolize_cache_entry(entry)
        {
          url: entry["url"],
          source: entry["source"],
          width: entry["width"],
          height: entry["height"],
          content_type: entry["content_type"]
        }.compact
      end
    end
  end
end
