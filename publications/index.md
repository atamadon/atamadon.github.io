---
layout: default
title: Publications
---

{% assign publications = site.data.generated.publications %}
{% assign featured_ids = site.data.featured_publications.featured_publication_ids | default: empty %}
{% assign journal_articles = publications | where: "subtype", "journal_article" %}
{% assign books = publications | where: "subtype", "book" %}
{% assign preprints = publications | where: "subtype", "preprint" %}
{% assign conference_papers = publications | where: "subtype", "conference" %}
{% assign book_chapters = publications | where: "subtype", "book_chapter" %}
{% assign reference_entries = publications | where: "subtype", "reference_entry" %}
{% assign repository_records = publications | where: "subtype", "repository" %}

<section class="publication-landing page-section">
  {% include section-heading.html title="Publications" %}
</section>

{% if featured_ids.size > 0 %}
  <section class="page-section">
    {% include section-heading.html title="Featured" %}
    <div class="publication-featured-carousel">
      <div class="publication-featured-track" aria-label="Featured publications">
      {% for featured_id in featured_ids %}
        {% assign publication = publications | where: "id", featured_id | first %}
        {% if publication %}
          <div class="publication-featured-slide">
            {% include publication-card.html publication=publication variant="featured" %}
          </div>
        {% endif %}
      {% endfor %}
      </div>
    </div>
  </section>
{% endif %}

<section class="page-section publication-filter-surface" id="publication-archive">
  {% include section-heading.html title="Browse" %}

  <fieldset class="publication-filter-fieldset">
    <legend class="visually-hidden">Filter publications by type</legend>
    <div class="publication-filter-chips">
    <a class="publication-filter-chip publication-filter-chip-reset" href="{{ '/publications/#publication-archive' | relative_url }}">All publications</a>
    <label class="publication-filter-chip" for="publication-filter-journal">
      <input class="publication-filter-input visually-hidden" type="checkbox" id="publication-filter-journal">
      <span>Journal articles</span>
    </label>
    <label class="publication-filter-chip" for="publication-filter-book">
      <input class="publication-filter-input visually-hidden" type="checkbox" id="publication-filter-book">
      <span>Books</span>
    </label>
    <label class="publication-filter-chip" for="publication-filter-preprint">
      <input class="publication-filter-input visually-hidden" type="checkbox" id="publication-filter-preprint">
      <span>Preprints</span>
    </label>
    <label class="publication-filter-chip" for="publication-filter-conference">
      <input class="publication-filter-input visually-hidden" type="checkbox" id="publication-filter-conference">
      <span>Conference papers</span>
    </label>
    <label class="publication-filter-chip" for="publication-filter-book-chapter">
      <input class="publication-filter-input visually-hidden" type="checkbox" id="publication-filter-book-chapter">
      <span>Book chapters</span>
    </label>
    <label class="publication-filter-chip" for="publication-filter-reference">
      <input class="publication-filter-input visually-hidden" type="checkbox" id="publication-filter-reference">
      <span>Reference entries</span>
    </label>
    <label class="publication-filter-chip" for="publication-filter-repository">
      <input class="publication-filter-input visually-hidden" type="checkbox" id="publication-filter-repository">
      <span>Repository records</span>
    </label>
    </div>
  </fieldset>

  <div class="publication-filter-panels">
    <div class="publication-filter-panel publication-filter-panel-all">
      {% include publication-archive.html publications=publications empty_message="No publications are available yet." %}
    </div>
    <div class="publication-filter-panel publication-filter-panel-journal">
      {% include publication-archive.html publications=journal_articles empty_message="No journal articles are available yet." %}
    </div>
    <div class="publication-filter-panel publication-filter-panel-book">
      {% include publication-archive.html publications=books empty_message="No books are available yet." %}
    </div>
    <div class="publication-filter-panel publication-filter-panel-preprint">
      {% include publication-archive.html publications=preprints empty_message="No preprints are available yet." %}
    </div>
    <div class="publication-filter-panel publication-filter-panel-conference">
      {% include publication-archive.html publications=conference_papers empty_message="No conference papers are available yet." %}
    </div>
    <div class="publication-filter-panel publication-filter-panel-book-chapter">
      {% include publication-archive.html publications=book_chapters empty_message="No book chapters are available yet." %}
    </div>
    <div class="publication-filter-panel publication-filter-panel-reference">
      {% include publication-archive.html publications=reference_entries empty_message="No reference entries are available yet." %}
    </div>
    <div class="publication-filter-panel publication-filter-panel-repository">
      {% include publication-archive.html publications=repository_records empty_message="No repository records are available yet." %}
    </div>
  </div>
</section>
