require "fileutils"
require "minitest/autorun"
require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/wordpress_news_media_localizer"

class WordpressNewsMediaLocalizerTest < Minitest::Test
  def test_localize_rewrites_legacy_urls_and_sets_featured_image
    Dir.mktmpdir do |dir|
      posts_dir = File.join(dir, "_posts")
      FileUtils.mkdir_p(posts_dir)
      post_path = File.join(posts_dir, "2024-05-02-example-post.md")

      File.write(post_path, <<~MARKDOWN)
        ---
        layout: post
        title: Example Post
        legacy_source_url: https://biomechanics.berkeley.edu/news/example-post
        legacy_featured_image_url: https://biomechanics.berkeley.edu/wp-content/uploads/2024/05/hero.jpg
        ---

        <p>Hello</p>
        <img src="https://biomechanics.berkeley.edu/wp-content/uploads/2024/05/detail.png" alt="">
      MARKDOWN

      downloaded = []
      downloader = lambda do |url, destination|
        downloaded << [url, destination]
        FileUtils.mkdir_p(File.dirname(destination))
        File.binwrite(destination, "image-bytes")
      end

      localizer = LabSite::WordpressNewsMediaLocalizer.new(root: dir, downloader: downloader)
      result = localizer.localize(post_path, write: true)

      assert_equal("/assets/images/news/example-post/01.jpg", result[:updated_front_matter]["featured_image"])
      assert_equal("Example Post", result[:updated_front_matter]["featured_image_alt"])
      assert_includes(result[:updated_content], "/assets/images/news/example-post/02.png")
      assert_equal(2, downloaded.length)
      assert(File.exist?(File.join(dir, "assets", "images", "news", "example-post", "01.jpg")))
      assert(File.exist?(File.join(dir, "assets", "images", "news", "example-post", "02.png")))
    end
  end

  def test_legacy_post_paths_only_select_imported_wordpress_posts
    Dir.mktmpdir do |dir|
      posts_dir = File.join(dir, "_posts")
      FileUtils.mkdir_p(posts_dir)
      File.write(File.join(posts_dir, "2024-05-02-legacy.md"), <<~MARKDOWN)
        ---
        layout: post
        title: Legacy
        legacy_source_url: https://biomechanics.berkeley.edu/news/legacy
        ---
      MARKDOWN
      File.write(File.join(posts_dir, "2026-01-01-local.md"), <<~MARKDOWN)
        ---
        layout: post
        title: Local
        ---
      MARKDOWN

      localizer = LabSite::WordpressNewsMediaLocalizer.new(root: dir, downloader: ->(*) {})
      paths = localizer.legacy_post_paths

      assert_equal(1, paths.length)
      assert_includes(paths.first, "2024-05-02-legacy.md")
    end
  end

  def test_localize_write_continues_when_a_legacy_asset_is_missing
    Dir.mktmpdir do |dir|
      posts_dir = File.join(dir, "_posts")
      FileUtils.mkdir_p(posts_dir)
      post_path = File.join(posts_dir, "2024-05-02-example-post.md")

      File.write(post_path, <<~MARKDOWN)
        ---
        layout: post
        title: Example Post
        legacy_source_url: https://biomechanics.berkeley.edu/news/example-post
        legacy_featured_image_url: https://biomechanics.berkeley.edu/wp-content/uploads/2024/05/hero.jpg
        ---

        <p>Hello</p>
        <img src="https://biomechanics.berkeley.edu/wp-content/uploads/2024/05/detail.png" alt="">
      MARKDOWN

      downloader = lambda do |url, destination|
        raise "404 Not Found" if url.end_with?("hero.jpg")

        FileUtils.mkdir_p(File.dirname(destination))
        File.binwrite(destination, "image-bytes")
      end

      localizer = LabSite::WordpressNewsMediaLocalizer.new(root: dir, downloader: downloader)
      result = localizer.localize(post_path, write: true)

      assert_equal(1, result[:localized_assets].length)
      assert_equal(1, result[:failed_assets].length)
      assert_nil(result[:updated_front_matter]["featured_image"])
      assert_equal("https://biomechanics.berkeley.edu/wp-content/uploads/2024/05/hero.jpg", result[:updated_front_matter]["legacy_featured_image_url"])
      assert_includes(result[:updated_content], "/assets/images/news/example-post/02.png")
    end
  end
end
