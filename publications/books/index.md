---
layout: default
title: Books
---

{% assign books = site.data.generated.publications | where: "type", "book" %}

<section class="publication-landing page-section">
  {% include section-heading.html eyebrow="Generated archive" title="Books" %}
  <p class="publication-intro">
    Books stay intentionally distinct from the journal archive. This page emphasizes covers and shelf browsing first, with citation details underneath each volume.
  </p>
  {% include publication-browse.html current="book" %}
</section>

<section class="books-library">
  {% if books.size > 0 %}
    <p class="books-library-intro">
      A small shelf of books connected to the lab's biomechanics and mechanobiology work.
      This page emphasizes covers and browsing first, then the full citation details.
    </p>

    <div class="bookshelf-grid">
    {% for publication in books %}
      {% include publication-card.html publication=publication variant="book" %}
    {% endfor %}
    </div>
  {% else %}
    <div class="publication-empty">
      <p>No books are available yet.</p>
    </div>
  {% endif %}
</section>
