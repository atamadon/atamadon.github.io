module LabSite
  class PublicationGenerator
    module ImageDiscovery
      private

      def resolve_image_metadata(source_url, image_resolver)
        cached = @cache.dig("resolved_images", source_url)
        if cached
          @stats["resolved_image_cache_hits"] += 1
          return symbolize_cache_entry(cached)
        end

        @stats["resolved_image_cache_misses"] += 1
        image_value = image_resolver.call(source_url)
        normalized = if image_value.is_a?(Hash)
          { url: image_value[:url] || image_value["url"], source: image_value[:source] || image_value["source"] }
        elsif image_value
          { url: image_value, source: "cover_or_preview" }
        else
          {}
        end

        store_cache_entry("resolved_images", source_url, normalized)
        normalized
      end

      def discover_image_for_source(source_url)
        final_url, html = fetch_html_document(source_url)
        return nil unless html

        figure_candidate = extract_figure_image(final_url, html)
        validated_figure = validate_image_candidate(figure_candidate)
        return validated_figure if validated_figure

        cover_candidate = extract_cover_image(final_url, html)
        validate_image_candidate(cover_candidate)
      rescue StandardError
        nil
      end

      def extract_figure_image(source_url, html)
        structured_candidate = extract_structured_figure_image(source_url, html)
        return structured_candidate if structured_candidate

        best_candidate = nil

        html.to_enum(:scan, /<img\b[^>]*>/im).each do
          tag = Regexp.last_match[0]
          offset = Regexp.last_match.begin(0)
          attributes = extract_html_attributes(tag)
          image_url = image_url_from_attributes(attributes, source_url)
          next unless image_url && likely_content_image?(image_url, attributes)

          score = figure_image_score(attributes, html, offset)
          next if score <= 0

          if best_candidate.nil? || score > best_candidate[:score]
            best_candidate = { url: image_url, source: "figure_1", score: score }
          end
        end

        best_candidate && { url: best_candidate[:url], source: best_candidate[:source] }
      end

      def extract_structured_figure_image(source_url, html)
        patterns = [
          /href=["']([^"']*figure\/image\?download[^"']*(?:g001|fig1)[^"']*)["']/i,
          /href=["']([^"']*figure\/image\?[^"']*(?:g001|fig1)[^"']*)["']/i,
          /src=["']([^"']*figure\/image\?[^"']*(?:g001|fig1)[^"']*)["']/i
        ]

        patterns.each do |pattern|
          match = html.match(pattern)
          next unless match

          return { url: URI.join(source_url, CGI.unescapeHTML(match[1])).to_s, source: "figure_1" }
        rescue URI::InvalidURIError
          next
        end

        nil
      end

      def extract_cover_image(source_url, html)
        meta_tags = html.scan(/<meta\b[^>]*>/i)
        meta_tags.each do |tag|
          attributes = extract_html_attributes(tag)
          value = (attributes["property"] || attributes["name"]).to_s.downcase
          next unless %w[citation_cover_image og:image twitter:image].include?(value)
          next unless attributes["content"]

          return { url: URI.join(source_url, attributes["content"]).to_s, source: "cover_or_preview" }
        end

        best_candidate = nil
        html.to_enum(:scan, /<img\b[^>]*>/im).each do
          tag = Regexp.last_match[0]
          attributes = extract_html_attributes(tag)
          image_url = image_url_from_attributes(attributes, source_url)
          next unless image_url && likely_content_image?(image_url, attributes)

          score = cover_image_score(attributes)
          next if score <= 0

          if best_candidate.nil? || score > best_candidate[:score]
            best_candidate = { url: image_url, source: "cover_or_preview", score: score }
          end
        end

        best_candidate && { url: best_candidate[:url], source: best_candidate[:source] }
      end

      def extract_html_attributes(tag)
        tag.scan(/([A-Za-z_:.-]+)=["']([^"']+)["']/).each_with_object({}) do |(key, value), attributes|
          attributes[key.downcase] = CGI.unescapeHTML(value)
        end
      end

      def image_url_from_attributes(attributes, source_url)
        candidates = [
          attributes["data-zoom-src"],
          attributes["data-hi-res-src"],
          attributes["data-full-src"],
          attributes["data-src"],
          attributes["src"],
          first_src_from_srcset(attributes["srcset"])
        ].compact

        raw_url = candidates.find do |value|
          image_file_path?(value) || known_image_endpoint?(value) || value.start_with?("http") || value.start_with?("/")
        end
        return nil unless raw_url

        URI.join(source_url, raw_url).to_s
      rescue URI::InvalidURIError
        nil
      end

      def first_src_from_srcset(srcset)
        return nil unless srcset

        srcset.split(",").map(&:strip).first&.split&.first
      end

      def figure_image_score(attributes, html, offset)
        context_start = [offset - 1200, 0].max
        context = html[context_start, 2400].to_s
        attribute_text = attributes.values.join(" ")
        score = 0
        score += 16 if figure_one_marker?(attribute_text)
        score += 14 if figure_one_marker?(context)
        score += 6 if attribute_text.match?(/\bfig(?:ure)?[-_\s]?1\b/i)
        score
      end

      def cover_image_score(attributes)
        attribute_text = attributes.values.join(" ")
        return -10 if figure_one_marker?(attribute_text)

        score = 0
        score += 8 if attribute_text.match?(/\bcover\b/i)
        score += 6 if attribute_text.match?(/\bjournal\b/i)
        score += 4 if attribute_text.match?(/\barticle\b|\bgraphical abstract\b/i)
        score
      end

      def figure_one_marker?(text)
        text.to_s.match?(/\b(?:figure|fig\.?)\s*1\b/i)
      end

      def likely_content_image?(image_url, attributes)
        combined = [image_url, attributes["alt"], attributes["class"], attributes["id"]].compact.join(" ").downcase
        return false if combined.match?(/logo|sprite|icon|avatar|orcid|favicon/)

        image_file_path?(image_url) || known_image_endpoint?(image_url)
      end

      def image_file_path?(value)
        value.to_s.match?(/\.(?:png|jpe?g|gif|webp|avif|svg)(?:\?|#|$)/i)
      end

      def known_image_endpoint?(value)
        value.to_s.match?(%r{article/(?:figure/image|file\?type=thumbnail)}i) ||
          value.to_s.match?(%r{/retrieve/pii/.+/gr\d+}i) ||
          value.to_s.match?(%r{/cms/asset/}i)
      end

      def fetch_html_document(source_url, redirects_remaining: MAX_REDIRECTS)
        uri = URI(source_url)
        response = fetch_response(uri, redirects_remaining: redirects_remaining)
        return [source_url, nil] unless response.is_a?(Net::HTTPSuccess)

        html = response.body.to_s
        redirect_target = extract_html_redirect_target(source_url, html)
        if redirect_target && redirects_remaining.positive? && redirect_target != source_url
          return fetch_html_document(redirect_target, redirects_remaining: redirects_remaining - 1)
        end

        [source_url, html]
      end

      def extract_html_redirect_target(source_url, html)
        meta_refresh = html.match(/http-equiv=["']refresh["'][^>]*content=["'][^"']*url=['"]?([^"'>]+)['"]?["']/i)
        if meta_refresh
          candidate = CGI.unescapeHTML(meta_refresh[1].strip)
          redirect_target = redirect_target_from_candidate(source_url, candidate)
          return redirect_target if redirect_target
        end

        redirect_url = html.match(/name=["']redirectURL["'][^>]*value=["']([^"']+)["']/i)
        return unless redirect_url

        CGI.unescapeHTML(redirect_url[1])
      end

      def redirect_target_from_candidate(source_url, candidate)
        uri = URI.join(source_url, candidate)
        params = CGI.parse(uri.query.to_s)
        redirect_param = params["Redirect"]&.first || params["redirect"]&.first || params["url"]&.first
        return CGI.unescapeHTML(redirect_param) if redirect_param

        uri.to_s
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
