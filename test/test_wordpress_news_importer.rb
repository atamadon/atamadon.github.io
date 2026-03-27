require "minitest/autorun"
require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/wordpress_export_inventory"
require "lab_site/wordpress_news_importer"

class WordpressNewsImporterTest < Minitest::Test
  SAMPLE_XML = <<~XML
    <?xml version="1.0" encoding="UTF-8" ?>
    <rss version="2.0"
      xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/"
      xmlns:content="http://purl.org/rss/1.0/modules/content/"
      xmlns:wfw="http://wellformedweb.org/CommentAPI/"
      xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:wp="http://wordpress.org/export/1.2/">
      <channel>
        <title>Example Lab</title>
        <link>https://example.com</link>
        <item>
          <title>Published News Item&nbsp;</title>
          <link>https://example.com/published-news-item</link>
          <dc:creator><![CDATA[editor]]></dc:creator>
          <content:encoded><![CDATA[<!-- wp:paragraph --><p>Hello world.</p><!-- /wp:paragraph -->]]></content:encoded>
          <wp:post_id>10</wp:post_id>
          <wp:post_date>2024-08-13 09:48:06</wp:post_date>
          <wp:status>publish</wp:status>
          <wp:post_name>published-news-item</wp:post_name>
          <wp:post_type>post</wp:post_type>
          <wp:postmeta>
            <wp:meta_key><![CDATA[_thumbnail_id]]></wp:meta_key>
            <wp:meta_value><![CDATA[99]]></wp:meta_value>
          </wp:postmeta>
        </item>
        <item>
          <title>Attachment</title>
          <link>https://example.com/wp-content/uploads/example.jpg</link>
          <dc:creator><![CDATA[editor]]></dc:creator>
          <wp:post_id>99</wp:post_id>
          <wp:post_date>2024-08-13 09:48:06</wp:post_date>
          <wp:status>inherit</wp:status>
          <wp:post_name>example-image</wp:post_name>
          <wp:post_type>attachment</wp:post_type>
          <wp:attachment_url>https://example.com/wp-content/uploads/example.jpg</wp:attachment_url>
        </item>
      </channel>
    </rss>
  XML

  def test_importable_posts_render_jekyll_post_front_matter
    inventory = LabSite::WordpressExportInventory.new(SAMPLE_XML)
    importer = LabSite::WordpressNewsImporter.new(inventory)

    record = importer.importable_posts.fetch(0)
    assert_equal("_posts/2024-08-13-published-news-item.md", record[:relative_path])
    assert_equal("Published News Item", record[:title])
    assert_equal("https://example.com/wp-content/uploads/example.jpg", record[:featured_image_url])
    assert_includes(record[:rendered], "layout: post")
    assert_includes(record[:rendered], "legacy_wordpress_post_id: '10'")
    assert_includes(record[:rendered], "legacy_featured_image_url: https://example.com/wp-content/uploads/example.jpg")
    assert_includes(record[:rendered], "<p>Hello world.</p>")
    refute_includes(record[:rendered], "<!-- wp:paragraph -->")
  end

  def test_write_posts_creates_files_and_skips_existing_by_default
    inventory = LabSite::WordpressExportInventory.new(SAMPLE_XML)
    importer = LabSite::WordpressNewsImporter.new(inventory)

    Dir.mktmpdir do |dir|
      result = importer.write_posts(output_root: dir, overwrite: false)
      assert_equal(1, result[:written].length)

      second = importer.write_posts(output_root: dir, overwrite: false)
      assert_equal(0, second[:written].length)
      assert_equal(1, second[:skipped].length)
    end
  end
end
