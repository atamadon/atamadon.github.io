---
layout: default
title: Books
---

# Books

<ul class="publication-list">
  {% assign books = site.publications | where: "type", "book" | sort: "date" | reverse %}
  {% for pub in books %}
    <li>
      <strong>{{ pub.title }}</strong><br />
      <em>{{ pub.authors }}</em><br />
      {{ pub.date | date: "%Y" }}<br />
      {% if pub.cover %}
      <img src="{{ pub.cover }}" alt="Cover of {{ pub.title }}" style="max-width:150px;"><br />
      {% endif %}
      <a href="{{ pub.link }}" target="_blank">View Book</a>
    </li>
  {% endfor %}
</ul>
