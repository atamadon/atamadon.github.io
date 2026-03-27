---
layout: default
title: Book Chapters
---

{% assign publications = site.data.generated.publications | where: "subtype", "book_chapter" %}

<section class="publication-landing page-section">
  {% include section-heading.html title="Book chapters" %}
  {% include publication-browse.html current="book_chapter" %}
</section>

<section class="page-section" id="book-chapter-archive">
  {% include publication-archive.html publications=publications empty_message="No book chapters are available yet." %}
</section>
