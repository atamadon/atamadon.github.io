require "fileutils"
require "minitest/autorun"
require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "lab_site/wayback_lab_news_importer"

class WaybackLabNewsImporterTest < Minitest::Test
  def test_parses_wayback_lab_news_entries_into_posts
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "_posts"))

      html = <<~HTML
        <div id="content">
          <h4>Feb 2015</h4>
          <p>Prof. Mohammad Mofrad is elected for American Institute for Medical and Biological Engineering (AIMBE)'s college of fellows.</p>
          <h4>Sep 23, 2011</h4>
          <p>Javad Golji completes his PhD thesis on "Molecular Dynamic of Mechanosensing". Congratulations, Dr. Golji!</p>
        </div>
      HTML

      importer = LabSite::WaybackLabNewsImporter.new(
        root: dir,
        html: html,
        source_url: "https://web.archive.org/example"
      )

      entries = importer.entries
      assert_equal(2, entries.length)
      assert_equal("Prof. Mohammad Mofrad is elected for American Institute for Medical and Biological Engineering (AIMBE)'s college of fellows.", entries[0][:title])
      assert_equal("Javad Golji completes his PhD thesis on \"Molecular Dynamic of Mechanosensing\".", entries[1][:title])
      assert_includes(entries[1][:rendered], "<p>Javad Golji completes his PhD thesis")
      assert_includes(entries[1][:relative_path], "2011-09-23-javad-golji-completes-his-phd-thesis")
    end
  end
end
