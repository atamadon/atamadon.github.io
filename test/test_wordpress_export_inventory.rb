require "csv"
require "minitest/autorun"
require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/wordpress_export_inventory"

class WordpressExportInventoryTest < Minitest::Test
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
          <title>Published News Item</title>
          <link>https://example.com/published-news-item</link>
          <dc:creator><![CDATA[editor]]></dc:creator>
          <wp:post_id>10</wp:post_id>
          <wp:post_date>2024-08-13 09:48:06</wp:post_date>
          <wp:status>publish</wp:status>
          <wp:post_name>published-news-item</wp:post_name>
          <wp:post_type>post</wp:post_type>
        </item>
        <item>
          <title>Draft News Item</title>
          <link>https://example.com/draft-news-item</link>
          <dc:creator><![CDATA[editor]]></dc:creator>
          <wp:post_id>11</wp:post_id>
          <wp:post_date>2024-08-14 09:48:06</wp:post_date>
          <wp:status>draft</wp:status>
          <wp:post_name>draft-news-item</wp:post_name>
          <wp:post_type>post</wp:post_type>
        </item>
        <item>
          <title>Research</title>
          <link>https://example.com/research</link>
          <dc:creator><![CDATA[editor]]></dc:creator>
          <wp:post_id>12</wp:post_id>
          <wp:post_date>2024-01-29 15:41:46</wp:post_date>
          <wp:status>publish</wp:status>
          <wp:post_name>research</wp:post_name>
          <wp:post_type>page</wp:post_type>
        </item>
        <item>
          <title>Hero Image</title>
          <link>https://example.com/wp-content/uploads/hero.jpg</link>
          <dc:creator><![CDATA[editor]]></dc:creator>
          <wp:post_id>13</wp:post_id>
          <wp:post_date>2024-01-29 15:41:46</wp:post_date>
          <wp:status>inherit</wp:status>
          <wp:post_name>hero-image</wp:post_name>
          <wp:post_type>attachment</wp:post_type>
          <wp:attachment_url>https://example.com/wp-content/uploads/hero.jpg</wp:attachment_url>
        </item>
      </channel>
    </rss>
  XML

  def test_inventory_summarizes_types_and_statuses
    inventory = LabSite::WordpressExportInventory.new(SAMPLE_XML)

    assert_equal("Example Lab", inventory.site_title)
    assert_equal("https://example.com", inventory.site_link)
    assert_equal(4, inventory.item_count)
    assert_equal({ "post" => 2, "page" => 1, "attachment" => 1 }, inventory.type_counts)
    assert_equal({ "publish" => 2, "draft" => 1, "inherit" => 1 }, inventory.status_counts)
    assert_equal(1, inventory.published_posts.length)
    assert_equal(1, inventory.published_pages.length)
  end

  def test_draft_ledger_rows_map_posts_and_pages
    inventory = LabSite::WordpressExportInventory.new(SAMPLE_XML)

    rows = inventory.draft_ledger_rows
    assert_equal(3, rows.length)

    post_row = rows.find { |row| row["legacy_id"] == "post-10-published-news-item" }
    assert_equal("news", post_row["content_type"])
    assert_equal("/news/", post_row["target_surface"])
    assert_equal("_posts/2024-08-13-published-news-item.md", post_row["target_path"])
    assert_equal("needs_import", post_row["content_status"])

    page_row = rows.find { |row| row["legacy_id"] == "page-12-research" }
    assert_equal("page", page_row["content_type"])
    assert_equal("", page_row["target_surface"])
    assert_equal("", page_row["target_path"])
    assert_includes(page_row["notes"], "Map this page to a current public route before import.")
  end

  def test_write_ledger_csv_outputs_headers_and_rows
    inventory = LabSite::WordpressExportInventory.new(SAMPLE_XML)

    Dir.mktmpdir do |dir|
      path = File.join(dir, "ledger.csv")
      inventory.write_ledger_csv(path)

      rows = CSV.read(path, headers: true)
      assert_equal(3, rows.length)
      assert_includes(rows.headers, "legacy_id")
      assert_equal("post-10-published-news-item", rows[0]["legacy_id"])
    end
  end
end
