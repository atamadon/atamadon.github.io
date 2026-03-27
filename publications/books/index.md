---
layout: default
title: Books
---

{% assign books = site.data.generated.publications | where: "type", "book" %}

<section class="publication-landing page-section">
  {% include section-heading.html title="Books" %}
</section>

<section class="books-library">
  {% if books.size > 0 %}
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
