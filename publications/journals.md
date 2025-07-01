---
layout: default
title: Journal Articles
---

# Journal Articles

<ul class="publication-list">
  {% assign journals = site.publications | where: "type", "journal" | sort: "date" | reverse %}
  {% for pub in journals %}
    <li>
      <strong>{{ pub.title }}</strong><br />
      <em>{{ pub.authors }}</em><br />
      {{ pub.date | date: "%Y" }}<br />
      {{ pub.citation }}<br />
      {% if pub.pdf %}
      <iframe src="{{ pub.pdf }}" width="100%" height="500px"></iframe>
      {% endif %}
    </li>
  {% endfor %}
</ul>
