---
layout: default
title: Publications
---

# All Publications

<ul class="publication-list">
  {% assign pubs = site.publications | sort: "date" | reverse %}
  {% for pub in pubs %}
    <li>
      <strong>{{ pub.title }}</strong><br />
      <em>{{ pub.authors }}</em><br />
      {{ pub.date | date: "%Y" }}<br />
      {% if pub.type == "journal" %}
        {{ pub.citation }}<br />
        {% if pub.pdf %}
        <iframe src="{{ pub.pdf }}" width="100%" height="500px"></iframe>
        {% endif %}
      {% elsif pub.type == "book" %}
        {% if pub.cover %}
        <img src="{{ pub.cover }}" alt="Cover of {{ pub.title }}" style="max-width:150px;"><br />
        {% endif %}
        <a href="{{ pub.link }}" target="_blank">View Book</a>
      {% endif %}
    </li>
  {% endfor %}
</ul>
