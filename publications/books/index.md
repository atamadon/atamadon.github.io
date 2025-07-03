---
layout: default
title: Books
---

# Books

<div class="book-grid">
  {% assign books = site.publications
     | where: "type", "book"
     | sort: "date" | reverse %}
  {% for pub in books %}
    {% assign href = pub.external_url | default: pub.url %}
    <div class="book-card">
      <h2 class="book-title">
        <a href="{{ href }}" target="_blank" rel="noopener">
          {{ pub.title }}
        </a>
      </h2>
      {% if pub.cover %}
        <a href="{{ href }}" target="_blank" rel="noopener">
          <img src="{{ pub.cover | relative_url }}"
               alt="Cover of {{ pub.title }}"
               class="book-cover" />
        </a>
      {% endif %}
      {% if pub.citation %}
        <p class="book-citation"><em>{{ pub.citation }}</em></p>
      {% endif %}
      {% if pub.authors %}
        <p class="book-authors">
          <strong>Authors:</strong> {{ pub.authors | join: ", " }}
        </p>
      {% endif %}
    </div>
  {% endfor %}
</div>
